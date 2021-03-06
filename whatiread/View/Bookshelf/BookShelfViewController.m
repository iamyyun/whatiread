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
#import <CloudKit/CloudKit.h>

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
    
    // localize language
    [self.addButton setTitle:NSLocalizedString(@"Add Book", @"") forState:UIControlStateNormal];
    [self.searchBar setPlaceholder:NSLocalizedString(@"Search with book title", @"")];
    [self.noBookLabel setText:NSLocalizedString(@"There is no registered book.", @"")];
    [self.sortLabel setText:NSLocalizedString(@"Complete Date", @"")];
    
    UIImage *image = [UIImage imageNamed:@"icon_menu_bookshelf_color"];
    [self setNaviBarType:BAR_MENU title:NSLocalizedString(@"Bookshelf", @"") image:image];
    
    [self.collectionView setAllowsSelection:YES];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BookShelfCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"BookShelfCollectionViewCell"];
    
    // Initialize coredata
    coreData = [CoreDataAccess sharedInstance];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
    
    // get Book data
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
        
        // check iCloud Data
        [self getiCloudData];
    }

    [self.bCountLabel setText:[NSString stringWithFormat:@"%ld", bookCount]];
    [self.bmCountLabel setText:[NSString stringWithFormat:@"%ld", bmCount]];
    
    // Sort PickerView
    sortArr = @[NSLocalizedString(@"Complete Date", @""), NSLocalizedString(@"Book Title", @""), NSLocalizedString(@"Rating", @"")];
    sortPickerView = [GKActionSheetPicker stringPickerWithItems:sortArr selectCallback:^(id selected) {
        [self sortBookshelf:selected];
    } cancelCallback:nil];
    sortPickerView.selectButtonTitle = NSLocalizedString(@"Done", @"");
    sortPickerView.cancelButtonTitle = NSLocalizedString(@"Cancel", @"");
    
    // Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShowNote:) name:UIWindowDidResignKeyNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHideNote:) name:UIWindowDidBecomeKeyNotification object:self.view.window];
    bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(writeFinished)];
    
    // top Constraint
    if ([self isiPad]) {
        self.topSearchConstraint.constant = 20.f;
        self.topConstraint.constant = 80.f;
    } else {
        if ([self isAfteriPhoneX]) {
            self.topSearchConstraint.constant = 44.f;
            self.topConstraint.constant = 103.f;
        } else {
            self.topSearchConstraint.constant = 20.f;
            self.topConstraint.constant = 80.f;
        }
    }
    [self updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.sortLabel setText:NSLocalizedString(@"Complete Date", @"")];
    
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
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate.alertWindow makeKeyAndVisible];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *strFirst = NSLocalizedString(@"Add book by searching", @"");
    NSString *strSecond = NSLocalizedString(@"Add book directly", @"");
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//        [appDelegate.alertWindow setHidden:YES];
        
        BookSearchViewController *searchVC = [[BookSearchViewController alloc] init];
        searchVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        searchVC.modalPresentationStyle = UIModalPresentationCurrentContext;
        [searchVC setBookSearchHandler:^(NSDictionary *bookDic) {
            if (bookDic) {
                if (![self isExistItem:bookDic]) {
                    [self bookConfigure:nil bookDic:bookDic indexPath:nil isSearchMode:YES];
                }
                else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"This book is already registered.", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                        [appDelegate.alertWindow setHidden:YES];
                    }];
                    [alert addAction:okAction];
                    [self presentController:alert animated:YES];
//                    [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                }
            }
        }];
        
        [self presentController:searchVC animated:YES];

    }];
    
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [appDelegate.alertWindow setHidden:YES];
        
        [self bookConfigure:nil bookDic:nil indexPath:nil isSearchMode:NO];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
//        [appDelegate.alertWindow setHidden:YES];
    }];
    
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:cancelAction];
    
    [self presentController:alert animated:YES];
//    [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];

}

// sort btn action
- (IBAction)sortBtnAction:(id)sender {
    [sortPickerView presentPickerOnView:self.view];
}

// mataData -> string
- (NSString *)makeMetaToString:(NSString *)strMeta {
    NSString *strResult = @"";
    NSString *style = @"<meta charset=\"UTF-8\"><style> body { font-family: 'HelveticaNeue'; font-size: 15px; } b {font-family: 'MarkerFelt-Wide'; }</style>";
    NSString *meta = [NSString stringWithFormat:@"%@%@", style, strMeta];
    NSDictionary *options = @{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithData:[meta dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:nil error:nil];
    strResult = [NSString stringWithFormat:@"%@", [attrString string]];
    
    return strResult;
}

// checking exist book item
- (BOOL)isExistItem:(NSDictionary *)dic {
    
    NSFetchRequest *request = [[self fetchedResultsController] fetchRequest];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@ AND author contains[cd] %@ AND isSearchMode == YES", [self makeMetaToString:[dic objectForKey:@"title"]], [self makeMetaToString:[dic objectForKey:@"author"]]];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
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
    if ([strSelect isEqualToString:NSLocalizedString(@"Complete Date", @"")]) {
        sortKey = @"completeDate";
    } else if ([strSelect isEqualToString:NSLocalizedString(@"Book Title", @"")]) {
        isAscending = YES;
        sortKey = @"title";
    } else if ([strSelect isEqualToString:NSLocalizedString(@"Rating" , @"")]) {
        sortKey = @"rate";
    }
    
    NSFetchRequest *request = [self.fetchedResultsController fetchRequest];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:isAscending];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    [self.collectionView reloadData];
}

// get Data from iCloud
- (void)getiCloudData
{
    if ([CloudKitManager isiCloudAccountIsSignedIn]) { // icloud account is signed in
        
        [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * _Nullable error) {
            if (error) {
                [self showAlertViewController:NSLocalizedString(@"iCloud is not available.", @"") msg:NSLocalizedString(@"iCloud is temporarily unavailable.", @"")];
            } else {
                if (accountStatus == CKAccountStatusAvailable) {
                    
//                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//                    [appDelegate.alertWindow makeKeyAndVisible];
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Do you want to restore data?", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//                        [appDelegate.alertWindow setHidden:YES];
                    }];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                        [appDelegate.alertWindow setHidden:YES];
                        
                        [self dismissViewControllerAnimated:YES completion:nil];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [IndicatorUtil startProcessIndicator];
                        });
                        
                        // iCloud data restore
                        [CloudKitManager fetchAllBooksWithCompletionHandler:^(NSArray *bResult, NSError *error) {
                            if (!error || error.code == 11) {
                                if (bResult && bResult.count > 0) {
                                    
                                    // refresh data
                                    self.managedObjectContext = nil;
                                    self.fetchedResultsController = nil;
                                    
                                    [coreData coreDataInitialize];
                                    self.fetchedResultsController = coreData.fetchedResultsController;
                                    self.fetchedResultsController.delegate = self;
                                    self.managedObjectContext = coreData.managedObjectContext;
                                    
                                    for (int i = 0; i < bResult.count; i++) {
                                        
                                        __block Book *resultBook = nil;
                                        
                                        [[CoreDataAccess sharedInstance] mapBook:bResult[i] completionHandler:^(Book *book) {
                                            if (book) {
                                                resultBook = book;

                                                NSError * error = nil;

                                                if(![self.managedObjectContext save:&error]) {
                                                    NSLog(@"Unresolved error = %@, %@", error, error.userInfo);
                                                    [self showAlertViewController:NSLocalizedString(@"Failed to save iCloud data", @"") msg:nil];
                                                } else {
                                                    NSLog(@"YJ << Success save iCloud data to CoreData");
                                                }
                                            }
                                        }];
                                        
                                        
                                        CKRecord *bRecord = bResult[i];
                                        
                                        [CloudKitManager fetchAllQuotesWithCompletionHandler:^(NSArray *quoteResult, NSError *error) {
                                            if (!error || error.code == 11) {
                                                if (quoteResult && quoteResult.count > 0) {
                                                    
                                                    for (int j = 0; j < quoteResult.count; j++) {
                                                        CKRecord *qRecord = quoteResult[j];
                                                        CKReference *qBookRef = qRecord[@"book"];
                                                        
                                                        CKRecordID *bookId = bRecord.recordID;
                                                        CKRecordID *qBookId = qBookRef.recordID;
                                                        
                                                        if ([bookId isEqual:qBookId]) {
                                                            
                                                            [[CoreDataAccess sharedInstance] mapQuote:qRecord completionHandler:^(Quote *quote) {
                                                                if (quote) {
                                                                    [resultBook addQuotesObject:quote];
                                                                    
                                                                    NSError *error = nil;
                                                                    
                                                                    if (![self.managedObjectContext save:&error]) {
                                                                        NSLog(@"Unresolved error = %@, %@", error, error.userInfo);
                                                                        [self showAlertViewController:NSLocalizedString(@"Failed to save iCloud data", @"") msg:nil];
                                                                    } else {
                                                                        if (j == quoteResult.count-1) {
                                                                            [IndicatorUtil stopProcessIndicator];
                                                                            [self.view makeToast:NSLocalizedString(@"Data restore succeed!", @"")];
                                                                        }
                                                                        NSLog(@"YJ << Success save iCloud data to CoreData - quote");
                                                                    }
                                                                }
                                                            }];
                                                        }
                                                    }
                                                } else {
                                                    [IndicatorUtil stopProcessIndicator];
//                                                    [self showAlertViewController:NSLocalizedString(@"No backup data exsits.", @"") msg:nil];
                                                }
                                            } else {
                                                [IndicatorUtil stopProcessIndicator];
                                                [self.view makeToast:NSLocalizedString(@"Data restore failed!", @"")];
                                            }
                                        }];
                                        
                                    }
                                    
                                    [self.collectionView reloadData];
                                } else {
                                    [IndicatorUtil stopProcessIndicator];
                                    [self showAlertViewController:NSLocalizedString(@"No backup data exsits.", @"") msg:nil];
                                }
                            } else {
                                [IndicatorUtil stopProcessIndicator];
                                [self.view makeToast:NSLocalizedString(@"Data restore failed!", @"")];
                            }
                        }];
                        
                    }];
                    
                    [alert addAction:cancelAction];
                    [alert addAction:okAction];
                    
                    [self presentController:alert animated:YES];
//                    [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                } else {
                    [self showAlertViewController:NSLocalizedString(@"iCloud is not available.", @"") msg:NSLocalizedString(@"iCloud is temporarily unavailable.", @"")];
                }
            }
        }];
        
    } else {
        [self showAlertViewController:NSLocalizedString(@"iCloud is disabled.", @"") msg:NSLocalizedString(@"iCloud is disalbed. Please enable iCloud Drive in Settings->iCloud.", @"")];
    }
}

- (void)showAlertViewController:(NSString *)title msg:(NSString *)msg {
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate.alertWindow makeKeyAndVisible];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [appDelegate.alertWindow setHidden:YES];
    }];
    [alert addAction:okAction];
    
    [self presentController:alert animated:YES];
//    [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
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
                    [self.view makeToast:NSLocalizedString(@"Succeeded to add book", @"")];
                } else {
                    [self.view makeToast:NSLocalizedString(@"Failed to add book", @"")];
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
                    [self.view makeToast:NSLocalizedString(@"Succeeded to modify book", @"")];
                } else {
                    [self.view makeToast:NSLocalizedString(@"Failed to modify book", @"")];
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
    }
}

// create bookmark
- (void)createBook:(NSDictionary *)bookDic isSearchMode:(BOOL)isSearchMode indexPath:(NSIndexPath *)indexPath completed:(void (^)(BOOL isResult))completed {
    
    // refresh data
    self.managedObjectContext = nil;
    self.fetchedResultsController = nil;
    
    [coreData coreDataInitialize];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSInteger bookCount = [sectionInfo numberOfObjects];
    NSInteger bookIndex = 0;
    
    // get LAST BOOK
    if (bookCount > 0) {
        NSArray *bookArr = [coreData getAllBooks];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        NSArray *afterBookArr = [bookArr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        Book *lastBook = afterBookArr[bookCount-1];
        bookIndex = lastBook.index+1;
    } else {
        bookIndex = 1;
    }
    
    NSDate *now = [[NSDate alloc] init];
    
    NSData *imageData = UIImagePNGRepresentation([bookDic objectForKey:@"bCoverImg"]);
    
    Book *book = [[Book alloc] initWithContext:self.managedObjectContext];
    book.index = bookIndex;
    book.title = [bookDic objectForKey:@"bTitle"];
    book.author = [bookDic objectForKey:@"bAuthor"];
    book.publisher = [bookDic objectForKey:@"bPublisher"];
    book.publishDate = [bookDic objectForKey:@"bPubDate"];
    book.startDate = [bookDic objectForKey:@"bStartDate"];
    book.completeDate = [bookDic objectForKey:@"bCompleteDate"];
    book.rate = [[bookDic objectForKey:@"bRate"] floatValue];
    book.review = @"";
    book.coverImg = imageData;
    book.createDate = now;
    book.modifyDate = now;
    book.isSearchMode = isSearchMode;
    
    
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
    [self.dimBgView setHidden:YES];
    [self.searchBar setHidden:YES];
    [self.searchBar setText:@""];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.sortLabel setText:NSLocalizedString(@"Complete Date", @"")];

    [self.collectionView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    isSearchBarActive = YES;
    [self.view addGestureRecognizer:bgTap];
    
    self.fetchedResultsController = nil;
    
    [coreData coreDataInitialize];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    
    NSFetchRequest *request = [self.fetchedResultsController fetchRequest];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchBar.text];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    [self.collectionView reloadData];
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
    
    NSLog(@"YJ << title : %@", book.title);
    NSLog(@"YJ << index : %i", book.index);
    
    cell.layer.borderColor = [UIColor colorWithHexString:@"333333"].CGColor;
    cell.layer.borderWidth = 1.0f;
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    if (isSearchBarActive) {
        if ([sectionInfo numberOfObjects] > 0) {
            [self.dimBgView setHidden:YES];
        } else {
            [self.dimBgView setHidden:NO];
        }
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
    isSearchBarActive = NO;
    [self.searchBar setText:@""];
    
    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    BookDetailViewController *detailVC = [[BookDetailViewController alloc] init];
    detailVC.book = book;
    [self pushController:detailVC animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.frame)-30, 90.0f);
}

#pragma mark - Fetched results controller
- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    if (controller == self.fetchedResultsController) {
        
        self.updateBlock = [NSBlockOperation new];
    }
}

- (void) controller:(NSFetchedResultsController *)controller didChangeSection:(nonnull id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    if (controller == self.fetchedResultsController) {
        
        __weak UICollectionView *collectionView = self.collectionView;
        
        switch(type) {
            case NSFetchedResultsChangeInsert: {
                [self.updateBlock addExecutionBlock:^{
                    [collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                }];
            }
                break;
            case NSFetchedResultsChangeDelete: {
                [self.updateBlock addExecutionBlock:^{
                    [collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                }];
            }
                break;
            default:
                return;
        }
    }
}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(nonnull id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    
    if (controller == self.fetchedResultsController) {
        
        __weak UICollectionView *collectionView = self.collectionView;
        
        [self.updateBlock addExecutionBlock:^{
            [collectionView reloadData];
        }];
    }
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if (controller == self.fetchedResultsController) {
        
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
        
        [self.collectionView performBatchUpdates:^{
            [[NSOperationQueue currentQueue] addOperation:self.updateBlock];
        } completion:^(BOOL finished) {
            [self.collectionView reloadData];
        }];
    }
}

#pragma mark - keyboard actions
- (void)handleKeyboardWillShowNote:(NSNotification *)notification
{
    [self.view addGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

- (void)handleKeyboardWillHideNote:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

@end
