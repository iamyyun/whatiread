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

@interface BookmarkViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>

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
//    [self setNaviBarType:BAR_SEARCH];
//    UISearchBar *searchBar = [[UISearchBar alloc] init];
//    [searchBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
//    [searchBar setPlaceholder:NSLocalizedString(@"Search with book title or quotes", @"")];
//    [searchBar setDelegate:self];
//    [searchBar setUserInteractionEnabled:YES];
//
//    UIView *searchBarContainer = [[UIView alloc] initWithFrame:searchBar.frame];
//    [searchBarContainer addSubview:searchBar];
    
//    if (@available(iOS 11.0, *)) {
//        self.navigationItem.searchController = searchBarContainer;
//    } else {
//        self.navigationItem.titleView = searchBarContainer;
//    }
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
        
    } bookDeleteCompleted:^(NSIndexPath *indexPath) {
        [self deleteBookmark:indexPath];
    }];
    
    [self pushController:addViewController animated:YES];
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

// delete bookmark
- (void)deleteBookmark:(NSIndexPath *)indexPath {
    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest <Book *> *fetchRequest = Book.fetchRequest;
    
    [context performBlock:^{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modifyDate" ascending:YES];
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
    
    //    PHAsset *asset = fetchResult[indexPath.item];
    //    NSLog(@"YJ << image creation date : %@", asset.creationDate);
    //    [imgManager requestImageForAsset:asset targetSize:cell.imgView.frame.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info)
    //     {
    //         NSLog(@"YJ << requestImageForAsset");
    //         [cell.imgView setImage:result];
    //     }];
//    [cell.imgView setImage:imgArr[indexPath.row]];
    
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
    
//    __block UIImage *dImg = [[UIImage alloc]init];
    
//    PHAsset *asset = fetchResult[indexPath.item];
//    [imgManager requestImageForAsset:asset targetSize:self.view.frame.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info)
//     {
//         dImg = result;
//     }];
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
    
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modifyDate" ascending:YES];
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

- (void) configureCell:(UITableViewCell *)cell withMessage:(Book *)accnt {
    __block BookmarkCollectionViewCell *bookCell = (Book *)cell;
    
//    [(BookmarkCollectionViewCell *)cell setAccountDetailHandler:^(Account *accnt) {
//        NSLog(@"YJ << set account detail handler");
//        [self updateAccnt:accnt bankName:accnt.bankName accntNum:accnt.accntNum accntOwner:accnt.accntOwner accntNick:accnt.accntNickName completed:^(BOOL isResult) {
//            NSString *result = @"";
//            if (isResult) {
//
//            }else {
//
//            }
//        }];
//    } accnt:accnt];
}

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView performBatchUpdates:^{} completion:^(BOOL finished){}];
}

- (void) controller:(NSFetchedResultsController *)controller didChangeSection:(nonnull id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
//            [self.accntTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
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
//            [self.accntTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
//            [self.accntTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[self.accntTableView cellForRowAtIndexPath:indexPath] withMessage:anObject];
            break;
        case NSFetchedResultsChangeMove:
//            [self configureCell:[self.accntTableView cellForRowAtIndexPath:indexPath] withMessage:anObject];
//            [self.accntTableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
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
    
    [self.collectionView reloadData];
}

@end
