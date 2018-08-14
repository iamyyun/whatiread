//
//  BookShelfViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 7. 13..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "BookShelfViewController.h"
#import "BookShelfCollectionViewCell.h"
#import "BookDetailViewController.h"
#import "AddBookViewController.h"
#import "WriteBookViewController.h"
#import "BookSearchViewController.h"
#import <GKActionSheetPicker/GKActionSheetPicker.h>

#define MILLI_SECONDS           1000.f

@interface BookShelfViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate> {
    CoreDataAccess *coreData;
    
    BOOL isSearchBarActive;
    GKActionSheetPicker *sortPickerView;
    NSArray *sortArr;
    
    UITapGestureRecognizer *bgTap;
}

@end

@implementation BookShelfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIImage *image = [UIImage imageNamed:@"icon_menu_bookshelf"];
    [self setNaviBarType:BAR_MENU title:NSLocalizedString(@"Bookshelf", @"") image:image];
    
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
            bmCount += book.quotes.count;
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
        [self sortBookshelf:selected];
    } cancelCallback:nil];
    sortPickerView.selectButtonTitle = @"완료";
    sortPickerView.cancelButtonTitle = @"취소";
    
    // Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShowNote:) name:UIWindowDidResignKeyNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHideNote:) name:UIWindowDidBecomeKeyNotification object:self.view.window];
    bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(writeFinished)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.managedObjectContext = nil;
    self.fetchedResultsController = nil;
    
    [coreData coreDataInitialize];
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
            bmCount += book.quotes.count;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) writeFinished {
    [self.view endEditing:YES];
    
    [self.view removeGestureRecognizer:bgTap];
}

#pragma mark - navigation action
- (void)rightBarBtnClick:(id)sender
{
    [self.dimBgView setHidden:NO];
    [self.searchBar setHidden:NO];
    [self.searchBar becomeFirstResponder];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.view addGestureRecognizer:bgTap];
    
}

#pragma mark - actions
// add bookmark btn action
- (IBAction)addBtnAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *strFirst = @"책 검색하여 등록";
    NSString *strSecond = @"직접 입력";
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        BookSearchViewController *searchVC = [[BookSearchViewController alloc] init];
        searchVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        searchVC.modalPresentationStyle = UIModalPresentationCurrentContext;
        [searchVC setBookSearchHandler:^(NSDictionary *bookDic) {
            if (bookDic) {
                if (![self isExistItem:bookDic]) {
                    [self bookConfigure:nil bookDic:bookDic indexPath:nil isSearchMode:YES];
                }
                else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"이미 등록된 책입니다." message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                    [alert addAction:okAction];
                    [self presentController:alert animated:YES];
                }
            }
        }];
        [self presentController:searchVC animated:YES];

    }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self bookConfigure:nil bookDic:nil indexPath:nil isSearchMode:NO];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:cancelAction];
    [self presentController:alert animated:YES];
}

// sort btn action
- (IBAction)sortBtnAction:(id)sender {
    [sortPickerView presentPickerOnView:self.view];
}

- (NSString *)makeMetaToString:(NSString *)strMeta {
    NSString *strResult = @"";
    NSString *style = @"<meta charset=\"UTF-8\"><style> body { font-family: 'HelveticaNeue'; font-size: 15px; } b {font-family: 'MarkerFelt-Wide'; }</style>";
    NSString *meta = [NSString stringWithFormat:@"%@%@", style, strMeta];
    NSDictionary *options = @{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithData:[meta dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:nil error:nil];
    strResult = [NSString stringWithFormat:@"%@", [attrString string]];
    
    return strResult;
}

- (BOOL)isExistItem:(NSDictionary *)dic {
    
    self.fetchedResultsController = nil;
    
    [coreData coreDataInitialize];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    
    NSFetchRequest *request = [[self fetchedResultsController] fetchRequest];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@ AND author contains[cd] %@ AND isSearchMode == YES", [self makeMetaToString:[dic objectForKey:@"title"]], [self makeMetaToString:[dic objectForKey:@"author"]]];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@ OR quotes contains[cd] %@", searchBar.text, searchBar.text];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSInteger count = [sectionInfo numberOfObjects];
    
    if (count > 0) {
        return YES;
    } else {
        return NO;
    }
}

// Sort Bookshelf CollectionView
- (void)sortBookshelf:(NSString *)strSelect {
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
- (void)bookConfigure:(Book *)book bookDic:(NSDictionary *)bookDic indexPath:(NSIndexPath *)indexPath isSearchMode:(BOOL)isSearchMode {
    
    if (isSearchMode) {
        AddBookViewController *addVC = [[AddBookViewController alloc] init];
        addVC.isModifyMode = NO;
        addVC.bookDic = bookDic;
        [addVC setAddBookCompositionHandler:bookDic addBookCreateCompleted:^(NSDictionary *dic){
            [self createBook:dic isSearchMode:YES indexPath:nil completed:^(BOOL isResult) {
                if (isResult) {
                    
                } else {
                    
                }
            }];
        } addBookModifyCompleted:nil];
        [self pushController:addVC animated:YES];
    } else {
        WriteBookViewController *writeVC = [[WriteBookViewController alloc] init];
        writeVC.isModifyMode = NO;
        [writeVC setWriteBookCompositionHandler:nil writeBookCreateCompleted:^(NSDictionary *dic){
            [self createBook:dic isSearchMode:NO indexPath:nil completed:^(BOOL isResult) {
                if (isResult) {
                    
                } else {
                    
                }
            }];
        } writeBookModifyCompleted:nil];
        [self pushController:writeVC animated:YES];
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

// create bookmark
- (void)createBook:(NSDictionary *)bookDic isSearchMode:(BOOL)isSearchMode indexPath:(NSIndexPath *)indexPath completed:(void (^)(BOOL isResult))completed {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSInteger bookCount = [sectionInfo numberOfObjects];
    
//    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSDate *now = [[NSDate alloc] init];
    
    NSData *imageData = UIImagePNGRepresentation([bookDic objectForKey:@"bCoverImg"]);
    
    Book *book = [[Book alloc] initWithContext:self.managedObjectContext];
    book.index = bookCount;
    book.title = [bookDic objectForKey:@"bTitle"];
    book.author = [bookDic objectForKey:@"bAuthor"];
    book.publisher = [bookDic objectForKey:@"bPublisher"];
    book.publishDate = [bookDic objectForKey:@"bPubDate"];
    book.startDate = [bookDic objectForKey:@"bStartDate"];
    book.completeDate = [bookDic objectForKey:@"bCompleteDate"];
    book.rate = [[bookDic objectForKey:@"bRate"] floatValue];
    book.coverImg = imageData;
//    book.quote = bookQuotes;
    book.modifyDate = now;
    book.isSearchMode = isSearchMode;
//    book.quoteImg = imageData;
    
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
    [self.view addGestureRecognizer:bgTap];
    
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
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yy.MM.dd"];
    NSString *strDate = [format stringFromDate:book.completeDate];
    
    cell.coverImgViewWidthConst.constant = 0.f;
    cell.titleLeadingMarginConst.constant = 0.f;
    cell.authorLeadingMarginConst.constant = 0.f;
    
    if (book.isSearchMode) {
        if (book.coverImg) {
            [cell.coverImgView setImage:[UIImage imageWithData:book.coverImg]];
            cell.coverImgViewWidthConst.constant = 51.f;
            cell.titleLeadingMarginConst.constant = 10.f;
            cell.authorLeadingMarginConst.constant = 10.f;
        }
    }
    [cell.titleLabel setText:book.title];
    [cell.authorLabel setText:book.author];
    [cell.bMarkCountLabel setText:[NSString stringWithFormat:@"%ld", book.quotes.count]];
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
    if ([sectionInfo numberOfObjects] > 0) {
        [self.dimBgView setHidden:YES];
    } else {
        [self.dimBgView setHidden:NO];
    }
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
    BookDetailViewController *detailVC = [[BookDetailViewController alloc] init];
    detailVC.indexPath = indexPath;
    detailVC.book = book;
    [self pushController:detailVC animated:YES];
    
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
    }
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
            bmCount += book.quotes.count;
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
    [self.view addGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

- (void)handleKeyboardWillHideNote:(NSNotification *)notification
{
    NSLog(@"YJ << keyboard hide");
    [self.view removeGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

@end
