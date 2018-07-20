//
//  BookShelfViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 7. 13..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "BookShelfViewController.h"
#import "BookShelfCollectionViewCell.h"
#import "BookShelfDetailViewController.h"
#import "AddBookShelfViewController.h"
#import <GKActionSheetPicker/GKActionSheetPicker.h>

#define MILLI_SECONDS           1000.f

@interface BookShelfViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate> {
    CoreDataAccess *coreData;
    
    BOOL isSearchBarActive;
    GKActionSheetPicker *sortPickerView;
    NSArray *sortArr;
    
    NSFetchedResultsChangeType *changeType;
}

@end

@implementation BookShelfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIImage *image = [UIImage imageNamed:@"icon_menu_bookshelf"];
    [self setNaviBarType:BAR_NORMAL title:NSLocalizedString(@"Bookshelf", @"") image:image];
    
    [self.collectionView setAllowsSelection:YES];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BookShelfCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"BookShelfCollectionViewCell"];
    
    coreData = [CoreDataAccess sharedInstance];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSInteger bookCount = [sectionInfo numberOfObjects];
    NSInteger bmCount = 0;
    if (bookCount > 0) {
        for (int i = 0; i < bookCount; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
            NSArray *arrQuotes = [NSArray arrayWithArray:book.quotes];
            bmCount += arrQuotes.count;
        }
        [self.collectionView setHidden:NO];
        [self.emptyView setHidden:YES];
    } else {
        [self.collectionView setHidden:YES];
        [self.emptyView setHidden:NO];
    }
    
    [self.bCountLabel setText:[NSString stringWithFormat:@"%ld", bookCount]];
    [self.bmCountLabel setText:[NSString stringWithFormat:@"%ld", bmCount]];
    
    // Sort PickerView
    sortArr = @[@"완독일", @"책 제목", @"평점"];
    sortPickerView = [GKActionSheetPicker stringPickerWithItems:sortArr selectCallback:^(id selected) {
        [self sortBookmark:selected];
    } cancelCallback:nil];
    sortPickerView.selectButtonTitle = @"완료";
    sortPickerView.cancelButtonTitle = @"취소";
    
    // Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShowNote:) name:UIWindowDidResignKeyNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHideNote:) name:UIWindowDidBecomeKeyNotification object:self.view.window];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.managedObjectContext = nil;
    self.fetchedResultsController = nil;
    
    [coreData coreDataInitialize];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - navigation action
- (void)rightBarBtnClick:(id)sender
{
    [self.searchBar setHidden:NO];
    [self.searchBar becomeFirstResponder];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - actions
// add bookmark btn action
- (IBAction)addBtnAction:(id)sender {
    [self bookConfigure:nil indexPath:nil isModifyMode:NO];
}

// sort btn action
- (IBAction)sortBtnAction:(id)sender {
    [sortPickerView presentPickerOnView:self.view];
}

// Sort Bookmark CollectionView
- (void)sortBookmark:(NSString *)strSelect {
    [self.sortLabel setText:strSelect];
    
    NSString *sortKey = @"";
    BOOL isAscending = NO;
    if ([strSelect isEqualToString:@"완독일"]) {
        sortKey = @"completeDate";
    } else if ([strSelect isEqualToString:@"책 제목"]) {
        isAscending = YES;
        sortKey = @"title";
    } else if ([strSelect isEqualToString:@"평점"]) {
        sortKey = @"rate";
    }
    
    self.fetchedResultsController = nil;
    
    [coreData coreDataInitialize];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    
    NSFetchRequest *request = [self.fetchedResultsController fetchRequest];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:isAscending];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    [self.collectionView reloadData];
//    [self.collectionView performBatchUpdates:^{
//        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
//    } completion:^(BOOL finished){
//    }];
}

#pragma mark - BookConfigure
- (void)bookConfigure:(Book *)book indexPath:(NSIndexPath *)indexPath isModifyMode:(BOOL)isModifyMode {
    
    if (isModifyMode) {
        BookShelfDetailViewController *detailVC = [[BookShelfDetailViewController alloc] init];
        detailVC.indexPath = indexPath;
        [detailVC setBookCompositionHandler:book bookModifyCompleted:^(NSString *bookTitle, NSString *bookAuthor, NSDate *bookDate, CGFloat fRate, NSMutableArray *bookQuotes, UIImage *bookImage){
            [self modifyBook:book bookTitle:bookTitle bookAuthor:bookAuthor compltDate:bookDate bookRate:fRate bookQuotes:bookQuotes bookImage:bookImage indexPath:indexPath completed:^(BOOL isResult) {
                if (isResult) {
                    
                } else {
                    
                }
            }];
        } bookDeleteCompleted:^(NSIndexPath *indexPath) {
            [self deleteBook:indexPath];
        } bookmarkDeleteCompleted:^(NSIndexPath *indexPath, NSInteger index, id <BookShelfViewControllerDelegate>delegate) {
            self.bookshelfDelegate = delegate;
            [self deleteBookmark:book indexPath:indexPath index:index completed:^(BOOL isResult, Book *book) {
                if (isResult) {
                    [self.bookshelfDelegate modifyBookCallback:book];
                } else {
                    
                }
            }];
        }];
        [self pushController:detailVC animated:YES];
    }
    else {
        AddBookShelfViewController *addVC = [[AddBookShelfViewController alloc] init];
        addVC.isModifyMode = NO;
        [addVC setBookCompositionHandler:^(NSString *bookTitle, NSString *bookAuthor, NSDate *bookDate, CGFloat fRate, NSMutableArray *bookQuotes, UIImage *bookImage){
            [self createBook:bookTitle bookAuthor:bookAuthor compltDate:bookDate bookRate:fRate bookQuotes:bookQuotes bookImage:bookImage indexPath:nil completed:^(BOOL isResult) {
                if (isResult) {
                    
                } else {
                    
                }
            }];
        } bookModifyCompleted:^(NSString *bookTitle, NSString *bookAuthor, NSDate *bookDate, CGFloat fRate, NSMutableArray *bookQuotes, UIImage *bookImage){
            [self modifyBook:book bookTitle:bookTitle bookAuthor:bookAuthor compltDate:bookDate bookRate:fRate bookQuotes:bookQuotes bookImage:bookImage indexPath:indexPath completed:^(BOOL isResult) {
                if (isResult) {
                    
                } else {
                    
                }
            }];
        }];
        
        [self pushController:addVC animated:YES];
    }
    
    if (isSearchBarActive) {
        isSearchBarActive = NO;
        
        // refresh data
        self.managedObjectContext = nil;
        self.fetchedResultsController = nil;
        
        [coreData coreDataInitialize];
        self.fetchedResultsController = coreData.fetchedResultsController;
        self.fetchedResultsController.delegate = self;
        self.managedObjectContext = coreData.managedObjectContext;
        
        [self.view endEditing:YES];
        [self.searchBar setHidden:YES];
        [self.searchBar setText:@""];
        [self.navigationController setNavigationBarHidden:NO animated:YES];

        [self.collectionView reloadData];
//        [self.collectionView performBatchUpdates:^{
//            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
//        } completion:^(BOOL finished){
//        }];
    }
}

// delete Book
- (void)deleteBook:(NSIndexPath *)indexPath {
    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest <Book *> *fetchRequest = Book.fetchRequest;
    
    [context performBlock:^{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completeDate" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"completeDate = %@", book.completeDate]];
        
        NSError * error;
        
        NSArray * resultArray = [context executeFetchRequest:fetchRequest error:&error];
        
        if([resultArray count]) {
            [context deleteObject:[resultArray lastObject]];
            [context save:&error];
        }
    }];
}

// delete Bookmark
- (void)deleteBookmark:(Book*)book indexPath:(NSIndexPath *)indexPath index:(NSInteger)index completed:(void (^)(BOOL isResult, Book *book))completed {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest <Book *> *fetchRequest = Book.fetchRequest;
    
    NSDate *now = [[NSDate alloc] init];
    
    [context performBlock:^{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completeDate" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"completeDate = %@", book.completeDate]];
        
        NSError * error;
        
        NSArray * resultArray = [context executeFetchRequest:fetchRequest error:&error];
        
        if([resultArray count]) {
            Book *book = [resultArray lastObject];
            
            NSMutableArray *quoteArr = [NSMutableArray arrayWithArray:(NSArray *)book.quotes];
            if (quoteArr && quoteArr.count > 0) {
                [quoteArr removeObjectAtIndex:index];
                book.quotes = quoteArr;
            }
//            if (bookQuotes) {
//                book.quotes = bookQuotes;
//            } else {
//                book.quotes = @"";
//            }
            
            book.modifyDate = now;
            
            [context save:&error];
            
            if (!error) {
                if (completed) {
                    completed(YES, book);
                }
            }
            else {
                if (completed) {
                    completed(NO, nil);
                }
            }
        }
        else {
            if (completed) {
                completed(NO, nil);
            }
        }
    }];
}

// create bookmark
- (void)createBook:(NSString *)bookTitle bookAuthor:(NSString *)bookAuthor compltDate:(NSDate *)compltDate bookRate:(CGFloat)bookRate bookQuotes:(NSMutableArray *)bookQuotes bookImage:(UIImage *)bookImage indexPath:(NSIndexPath *)indexPath completed:(void (^)(BOOL isResult))completed {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSInteger bookCount = [sectionInfo numberOfObjects];
    
//    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSDate *now = [[NSDate alloc] init];
    //    int64_t tempBookID = ([now timeIntervalSince1970] * MILLI_SECONDS);
    
    NSData *imageData = UIImagePNGRepresentation(bookImage);
    
    Book *book = [[Book alloc] initWithContext:self.managedObjectContext];
    book.index = bookCount;
    book.title = bookTitle;
    book.author = bookAuthor;
    book.completeDate = compltDate;
    book.rate = bookRate;
    book.quotes = bookQuotes;
    book.modifyDate = now;
    book.image = imageData;
    
    NSError * error = nil;
    
    if(![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error = %@, %@", error, error.userInfo);
        if(completed) {
            completed(NO);
        }
    }
    else {
        completed(YES);
    }
}

// modify bookmark
- (void)modifyBook:(Book *)book bookTitle:(NSString *)bookTitle bookAuthor:(NSString *)bookAuthor compltDate:(NSDate *)compltDate bookRate:(CGFloat)bookRate bookQuotes:(NSMutableArray *)bookQuotes bookImage:(UIImage *)bookImage indexPath:(NSIndexPath *)indexPath completed:(void (^)(BOOL isResult))completed {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest <Book *> *fetchRequest = Book.fetchRequest;
    
    NSDate *now = [[NSDate alloc] init];
    
    [context performBlock:^{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completeDate" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"completeDate = %@", book.completeDate]];
        
        NSError * error;
        
        NSArray * resultArray = [context executeFetchRequest:fetchRequest error:&error];
        
        if([resultArray count]) {
            Book *book = [resultArray lastObject];
            if (bookTitle) {
                book.title = bookTitle;
            } else {
                book.title = @"";
            }
            
            if (bookAuthor) {
                book.author = bookAuthor;
            } else {
                book.author = @"";
            }
            
            if (compltDate) {
                book.completeDate = compltDate;
            } else {
                book.completeDate = [NSDate date];
            }
            
            if (bookRate) {
                book.rate = bookRate;
            } else {
                book.rate = 0.f;
            }
            
            if (bookQuotes) {
                book.quotes = bookQuotes;
            } else {
                book.quotes = @"";
            }
            
            if (bookImage) {
                NSData *imageData = UIImagePNGRepresentation(bookImage);
                book.image = imageData;
            } else {
                book.image = nil;
            }
            
            book.modifyDate = now;
            
            [context save:&error];
            
            if (!error) {
                if (completed) {
                    completed(YES);
                }
            }
            else {
                if (completed) {
                    completed(NO);
                }
            }
        }
        else {
            if (completed) {
                completed(NO);
            }
        }
    }];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    isSearchBarActive = NO;
    
    self.managedObjectContext = nil;
    self.fetchedResultsController = nil;
    
    [coreData coreDataInitialize];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
    
    [self.view endEditing:YES];
    [self.searchBar setHidden:YES];
    [self.searchBar setText:@""];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [self.collectionView reloadData];
//    [self.collectionView performBatchUpdates:^{
//        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
//    } completion:^(BOOL finished){
//    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    isSearchBarActive = YES;
    
    self.fetchedResultsController = nil;
    
    [coreData coreDataInitialize];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    
    NSFetchRequest *request = [[self fetchedResultsController] fetchRequest];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchBar.text];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@ OR quotes contains[cd] %@", searchBar.text, searchBar.text];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    [self.collectionView reloadData];
//    [self.collectionView performBatchUpdates:^{
//        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
//    } completion:^(BOOL finished){
//    }];
}

#pragma mark - UICollectionViewDataSource
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"BookShelfCollectionViewCell";
    BookShelfCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
    }
    
    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSMutableArray *quoteArr = [NSMutableArray arrayWithArray:book.quotes];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yy.MM.dd"];
    NSString *strDate = [format stringFromDate:book.completeDate];
    
    [cell.titleLabel setText:book.title];
    [cell.authorLabel setText:book.author];
    [cell.bMarkCountLabel setText:[NSString stringWithFormat:@"%ld", quoteArr.count]];
    [cell.compDateLabel setText:strDate];
    [cell.rateLabel setText:[[NSNumber numberWithFloat:book.rate] stringValue]];
    
    cell.layer.borderColor = [UIColor darkGrayColor].CGColor;
    cell.layer.borderWidth = 1.0f;
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSLog(@"YJ << section %ld - item %ld", section, [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"YJ << select collectionview cell");
    
    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self bookConfigure:book indexPath:indexPath isModifyMode:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.frame)-30, 90.0f);
}

#pragma mark - Fetched results controller
- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    //    [self.collectionView performBatchUpdates:^{} completion:^(BOOL finished){}];
}

- (void) controller:(NSFetchedResultsController *)controller didChangeSection:(nonnull id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            break;
        case NSFetchedResultsChangeDelete:
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            break;
        default:
            return;
    }
}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(nonnull id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    
    NSLog(@"YJ << section : %ld", newIndexPath.section);
    NSLog(@"YJ << item : %ld", newIndexPath.item);
    
    self.fetchedResultsController = nil;
    self.managedObjectContext = nil;
    
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
    
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
//            break;
//        case NSFetchedResultsChangeDelete:
//            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
//            break;
//        case NSFetchedResultsChangeUpdate:
//            [self.collectionView reloadItemsAtIndexPaths:@[newIndexPath]];
//            break;
//        case NSFetchedResultsChangeMove:
//            [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
//            break;
//    }
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    id <NSFetchedResultsSectionInfo> sectionInfo = [controller sections][0];
    NSInteger bookCount = [sectionInfo numberOfObjects];
    NSInteger bmCount = 0;
    if (bookCount > 0) {
        for (int i = 0; i < bookCount; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
            NSArray *arrQuotes = [NSArray arrayWithArray:book.quotes];
            bmCount += arrQuotes.count;
        }
        [self.collectionView setHidden:NO];
        [self.emptyView setHidden:YES];
    } else {
        [self.collectionView setHidden:YES];
        [self.emptyView setHidden:NO];
    }
    
    [self.bCountLabel setText:[NSString stringWithFormat:@"%ld", bookCount]];
    [self.bmCountLabel setText:[NSString stringWithFormat:@"%ld", bmCount]];
    
//    [self.collectionView performBatchUpdates:^{
//        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
//    } completion:^(BOOL finished){
//    }];
    [self.collectionView reloadData];
}

#pragma mark - keyboard actions
- (void)handleKeyboardWillShowNote:(NSNotification *)notification
{
    
    NSLog(@"YJ << keyboard show");
    //    [self.view addGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

- (void)handleKeyboardWillHideNote:(NSNotification *)notification
{
    NSLog(@"YJ << keyboard hide");
    //    [self.view removeGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

@end
