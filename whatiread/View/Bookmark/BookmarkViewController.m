//
//  BookmarkViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 6. 4..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "BookmarkViewController.h"
#import "BookmarkCollectionViewCell.h"
#import "BookMarkHeaderCollectionReusableView.h"
#import "AddBookmarkViewController.h"
#import <GKActionSheetPicker/GKActionSheetPicker.h>

#define MILLI_SECONDS           1000.f

@interface BookmarkViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate> {
    CoreDataAccess *coreData;
    
    BOOL isSearchBarActive;
    GKActionSheetPicker *sortPickerView;
    NSArray *sortArr;
}

@end

@implementation BookmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIImage *image = [UIImage imageNamed:@"icon_menu_bookmark"];
    [self setNaviBarType:BAR_NORMAL title:NSLocalizedString(@"Bookmark", @"") image:image];
    
    [self.collectionView setAllowsSelection:YES];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BookmarkCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"BookmarkCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BookMarkHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"BookMarkHeaderCollectionReusableView"];
    
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
}

#pragma mark - BookConfigure
- (void)bookConfigure:(Book *)book indexPath:(NSIndexPath *)indexPath isModifyMode:(BOOL)isModifyMode {
    AddBookmarkViewController *addViewController = [[AddBookmarkViewController alloc] init];
    addViewController.indexPath = indexPath;
    addViewController.isModifyMode = isModifyMode;
    
    [addViewController setBookCompositionHandler:book bookCreateCompleted:^(NSString *bookTitle, NSString *bookAuthor, NSDate *bookDate, CGFloat fRate, NSMutableArray *bookQuotes, UIImage *bookImage) {
        [self createBookmark:bookTitle bookAuthor:bookAuthor compltDate:bookDate bookRate:fRate bookQuotes:bookQuotes bookImage:bookImage indexPath:indexPath completed:^(BOOL isResult) {
            if (isResult) {
                
            } else {
                
            }
        }];
    } bookModifyCompleted:^(NSString *bookTitle, NSString *bookAuthor, NSDate *bookDate, CGFloat fRate, NSMutableArray *bookQuotes, UIImage *bookImage) {
        [self modifyBookmark:book bookTitle:bookTitle bookAuthor:bookAuthor compltDate:bookDate bookRate:fRate bookQuotes:bookQuotes bookImage:bookImage indexPath:indexPath completed:^(BOOL isResult) {
            if (isResult) {
                
            } else {
                
            }
        }];
    } bookDeleteCompleted:^(NSIndexPath *indexPath) {
        [self deleteBookmark:indexPath];
    }];
    
    [self pushController:addViewController animated:YES];
    
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

// create bookmark
- (void)createBookmark:(NSString *)bookTitle bookAuthor:(NSString *)bookAuthor compltDate:(NSDate *)compltDate bookRate:(CGFloat)bookRate bookQuotes:(NSMutableArray *)bookQuotes bookImage:(UIImage *)bookImage indexPath:(NSIndexPath *)indexPath completed:(void (^)(BOOL isResult))completed {
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
- (void)modifyBookmark:(Book *)book bookTitle:(NSString *)bookTitle bookAuthor:(NSString *)bookAuthor compltDate:(NSDate *)compltDate bookRate:(CGFloat)bookRate bookQuotes:(NSMutableArray *)bookQuotes bookImage:(UIImage *)bookImage indexPath:(NSIndexPath *)indexPath completed:(void (^)(BOOL isResult))completed {
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

// delete bookmark
- (void)deleteBookmark:(NSIndexPath *)indexPath {
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
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    isSearchBarActive = YES;

    self.fetchedResultsController = nil;
    
    [coreData coreDataInitialize];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    
    NSFetchRequest *request = [self.fetchedResultsController fetchRequest];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchBar.text];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@ OR quotes contains[cd] %@", searchBar.text, searchBar.text];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sortDescriptor]];

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"BookmarkCollectionViewCell";
    BookmarkCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
    }
    
    NSLog(@"YJ << section : %ld", indexPath.section);
    NSLog(@"YJ << item : %ld", indexPath.item);
    NSIndexPath *fetchIndexPath = [NSIndexPath indexPathForItem:indexPath.section inSection:0];
    Book *book = [self.fetchedResultsController objectAtIndexPath:fetchIndexPath];
    
    NSMutableArray *quoteArr = [NSMutableArray arrayWithArray:book.quotes];
    if (quoteArr && quoteArr.count > 0) {
        NSString *strQuote = quoteArr[indexPath.item];
        
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        CGFloat height = [strQuote boundingRectWithSize:CGSizeMake(cell.quoteLabel.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f], NSParagraphStyleAttributeName:paragraph} context:nil].size.height;
        [cell.quoteLabel setText:quoteArr[indexPath.item]];
        cell.quoteLabelHeightConst.constant = height;
    }

    [cell.indexLabel setText:[NSString stringWithFormat:@"%ld", (indexPath.item+1)]];

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    BookMarkHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"BookMarkHeaderCollectionReusableView" forIndexPath:indexPath];
    
    NSIndexPath *fetchIndexPath = [NSIndexPath indexPathForItem:indexPath.section inSection:0];
    Book *book = [self.fetchedResultsController objectAtIndexPath:fetchIndexPath];
    NSArray *quoteArr = (NSArray *)book.quotes;
    
    [headerView.titleLabel setText:book.title];
    [headerView.bmCountLabel setText:[NSString stringWithFormat:@"%ld", quoteArr.count]];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSLog(@"YJ << section %ld", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:section inSection:0];
    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSArray *quoteArr = (NSArray *)book.quotes;
    NSLog(@"YJ << item %ld - %ld", section, quoteArr.count);
    return quoteArr.count;
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
    
    NSIndexPath *fetchIndexPath = [NSIndexPath indexPathForItem:indexPath.section inSection:0];
    Book *book = [self.fetchedResultsController objectAtIndexPath:fetchIndexPath];
    [self bookConfigure:book indexPath:fetchIndexPath isModifyMode:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = self.collectionView.frame.size.width;
    CGFloat height = 100.f;
    NSIndexPath *fetchIndexPath = [NSIndexPath indexPathForItem:indexPath.section inSection:0];
    Book *book = [self.fetchedResultsController objectAtIndexPath:fetchIndexPath];
    
    NSMutableArray *quoteArr = [NSMutableArray arrayWithArray:book.quotes];
    if (quoteArr && quoteArr.count > 0) {
        NSString *strQuote = quoteArr[indexPath.item];
        
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        height = [strQuote boundingRectWithSize:CGSizeMake(width - 61, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f], NSParagraphStyleAttributeName:paragraph} context:nil].size.height;
    }
    
    return CGSizeMake(self.collectionView.frame.size.width, (height+20));
}

#pragma mark - Fetched results controller
- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
}

//- (void) controller:(NSFetchedResultsController *)controller didChangeSection:(nonnull id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
//            break;
//        case NSFetchedResultsChangeDelete:
//            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
//            break;
//        default:
//            return;
//    }
//}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(nonnull id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.item]];
//            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            break;
        case NSFetchedResultsChangeDelete:
//            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.item]];
            break;
        case NSFetchedResultsChangeUpdate:
//            [self.collectionView reloadItemsAtIndexPaths:@[newIndexPath]];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.item]];
            break;
        case NSFetchedResultsChangeMove:
//            [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            [self.collectionView moveSection:indexPath.item toSection:newIndexPath.item];
            break;
    }
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
