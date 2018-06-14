//
//  BookmarkViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 6. 4..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "BookmarkViewController.h"
#import "BookmarkCollectionViewCell.h"
#import "AddBookmarkViewController.h"
#import "CoreDataAccess.h"

#define MILLI_SECONDS           1000.f

@interface BookmarkViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate> {
    BOOL isSearchBarActive;
}

@end

@implementation BookmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNaviBarType:BAR_NORMAL];
    
    [self.collectionView setAllowsSelection:YES];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BookmarkCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"BookmarkCollectionViewCell"];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSInteger bookCount = [sectionInfo numberOfObjects];
    if (bookCount > 0) {
        [self.collectionView setHidden:NO];
        [self.emptyView setHidden:YES];
    } else {
        [self.collectionView setHidden:YES];
        [self.emptyView setHidden:NO];
    }
    
    [self.countLabel setText:[NSString stringWithFormat:@"%ld", bookCount]];
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

#pragma mark - BookConfigure
- (void)bookConfigure:(Book *)book indexPath:(NSIndexPath *)indexPath isModifyMode:(BOOL)isModifyMode {
    AddBookmarkViewController *addViewController = [[AddBookmarkViewController alloc] init];
    addViewController.indexPath = indexPath;
    addViewController.isModifyMode = isModifyMode;
    
    [addViewController setBookCompositionHandler:book bookCreateCompleted:^(NSString *bookTitle, NSString *bookAuthor, NSString *bookQuote, UIImage *bookImage) {
        [self createBookmark:bookTitle bookAuthor:bookAuthor bookQuote:bookQuote bookImage:bookImage indexPath:indexPath completed:^(BOOL isResult) {
            if (isResult) {
                
            } else {
                
            }
        }];
    } bookModifyCompleted:^(NSString *bookTitle, NSString *bookAuthor, NSString *bookQuote, UIImage *bookImage) {
        [self modifyBookmark:book bookTitle:bookTitle bookAuthor:bookAuthor bookQuote:bookQuote bookImage:bookImage indexPath:indexPath completed:^(BOOL isResult) {
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
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSFetchRequest <Book *> *fetchRequest = Book.fetchRequest;
        
        [context performBlock:^{
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modifyDate" ascending:NO];
            [fetchRequest setSortDescriptors:@[sortDescriptor]];
            
            NSError * error;
            
            self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
            [self.fetchedResultsController performFetch:&error];
            
            [self.collectionView reloadData];
        }];
        
        [self.view endEditing:YES];
        [self.searchBar setHidden:YES];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

// create bookmark
- (void)createBookmark:(NSString *)bookTitle bookAuthor:(NSString *)bookAuthor bookQuote:(NSString *)bookQuote bookImage:(UIImage *)bookImage indexPath:(NSIndexPath *)indexPath completed:(void (^)(BOOL isResult))completed {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSInteger bookCount = [sectionInfo numberOfObjects];
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSDate *now = [[NSDate alloc] init];
//    int64_t tempBookID = ([now timeIntervalSince1970] * MILLI_SECONDS);
    
    NSData *imageData = UIImagePNGRepresentation(bookImage);
    
    Book *book = [[Book alloc] initWithContext:context];
    book.index = bookCount;
    book.title = bookTitle;
    book.author = bookAuthor;
    book.quotes = bookQuote;
    book.modifyDate = now;
    book.image = imageData;
    
    NSError * error = nil;
    
    if(![context save:&error]) {
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
- (void)modifyBookmark:(Book *)book bookTitle:(NSString *)bookTitle bookAuthor:(NSString *)bookAuthor bookQuote:(NSString *)bookQuote bookImage:(UIImage *)bookImage indexPath:(NSIndexPath *)indexPath completed:(void (^)(BOOL isResult))completed {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest <Book *> *fetchRequest = Book.fetchRequest;
    
    NSDate *now = [[NSDate alloc] init];
    
    [context performBlock:^{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modifyDate" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"modifyDate = %@", book.modifyDate]];
        
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
            
            if (bookQuote) {
                book.quotes = bookQuote;
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
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modifyDate" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"modifyDate = %@", book.modifyDate]];
        
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
    
    // refresh data
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest <Book *> *fetchRequest = Book.fetchRequest;
    
    [context performBlock:^{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modifyDate" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        
        NSError * error;
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        [self.fetchedResultsController performFetch:&error];
        
        [self.collectionView reloadData];
    }];
    
    [self.view endEditing:YES];
    [self.searchBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    isSearchBarActive = YES;
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest <Book *> *fetchRequest = Book.fetchRequest;
    
    [context performBlock:^{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modifyDate" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title contains[cd] %@ OR quotes contains[cd] %@", searchBar.text, searchBar.text]];
//        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title contains[cd] %@", searchBar.text]];
        
        NSError * error;
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        [self.fetchedResultsController performFetch:&error];
        
        [self.collectionView reloadData];
    }];
    NSLog(@"YJ << searchBar search button clicked");
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    isSearchBarActive = YES;
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest <Book *> *fetchRequest = Book.fetchRequest;
    
    [context performBlock:^{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modifyDate" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title contains[cd] %@ OR quotes contains[cd] %@", searchBar.text, searchBar.text]];
        
        NSError * error;
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        [self.fetchedResultsController performFetch:&error];
        
        [self.collectionView reloadData];
    }];
    NSLog(@"YJ << search bar text : %@", searchText);
}

#pragma mark - UICollectionViewDataSource
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"BookmarkCollectionViewCell";
    BookmarkCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
    }
    
    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell.titleLabel setText:book.title];
    [cell.quoteLabel setText:book.quotes];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:book.modifyDate
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    [cell.dateLabel setText:dateString];
    if (book.image) {
        UIImage *image = [UIImage imageWithData:book.image];
        [cell.imageView setImage:image];
        cell.constImageWidth.constant = 47.0f;
    } else {
        cell.constImageWidth.constant = 0.0f;
    }
    
    cell.layer.borderColor = [UIColor darkGrayColor].CGColor;
    cell.layer.borderWidth = 1.0f;
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
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

#pragma mark - Fetched results controller
- (NSFetchedResultsController <Book *> *)fetchedResultsController {
    if(_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    if(_managedObjectContext == nil) {
        CoreDataAccess *coreData = [CoreDataAccess sharedInstance];
        _managedObjectContext = coreData.persistentContainer.viewContext;
    }
    
    NSFetchRequest <Book *> * fetchRequest = Book.fetchRequest;
    
    [fetchRequest setFetchBatchSize:30];
    
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modifyDate" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSFetchedResultsController <Book *> *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:@"MainBookList"];
    aFetchedResultsController.delegate = self;
    
    NSError * error = nil;
    
    if(![aFetchedResultsController performFetch:&error]) {
        abort();
    }
    
    _fetchedResultsController = aFetchedResultsController;
    
    return _fetchedResultsController;
}

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [self.collectionView performBatchUpdates:^{} completion:^(BOOL finished){}];
}

- (void) controller:(NSFetchedResultsController *)controller didChangeSection:(nonnull id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
//            [self.accntTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
//            [self.accntTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            return;
    }
}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(nonnull id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    //    UITableView * tableView = self.accntTableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            break;
        case NSFetchedResultsChangeDelete:
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.collectionView reloadItemsAtIndexPaths:@[newIndexPath]];
            break;
        case NSFetchedResultsChangeMove:
            [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    id <NSFetchedResultsSectionInfo> sectionInfo = [controller sections][0];
    NSInteger bookCount = [sectionInfo numberOfObjects];
    if (bookCount > 0) {
        [self.collectionView setHidden:NO];
        [self.emptyView setHidden:YES];
    } else {
        [self.collectionView setHidden:YES];
        [self.emptyView setHidden:NO];
    }
    
    [self.countLabel setText:[NSString stringWithFormat:@"%ld", bookCount]];
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished){
    }];
//    [self.collectionView reloadData];
}

@end
