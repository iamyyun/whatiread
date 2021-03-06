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
#import "BookmarkDetailViewController.h"
#import <GKActionSheetPicker/GKActionSheetPicker.h>

#define MILLI_SECONDS           1000.f

@interface BookmarkViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate> {
    CoreDataAccess *coreData;
    
    BOOL isSearchBarActive;
    GKActionSheetPicker *sortPickerView;
    NSArray *sortArr;
    
    UITapGestureRecognizer *bgTap;
}

@end

@implementation BookmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIImage *image = [UIImage imageNamed:@"icon_menu_bookmark_color"];
    [self setNaviBarType:BAR_MENU title:NSLocalizedString(@"Bookmark", @"") image:image];
    
    // localize language
    [self.searchBar setPlaceholder:NSLocalizedString(@"Search with book quotes", @"")];
    [self.noBookLangLabel setText:NSLocalizedString(@"There is no registered book.", @"")];
    [self.sortLabel setText:NSLocalizedString(@"Complete Date", @"")];
    
    [self.collectionView setAllowsSelection:YES];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BookmarkCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"BookmarkCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BookMarkHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"BookMarkHeaderCollectionReusableView"];
    
    coreData = [CoreDataAccess sharedInstance];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.quoteFetchedResultsController = coreData.quoteFetchedResultsController;
    self.quoteFetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
    self.quoteManagedObjectContext = coreData.quoteManagedObjectContext;
    
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
    sortArr = @[NSLocalizedString(@"Complete Date", @""), NSLocalizedString(@"Book Title", @""), NSLocalizedString(@"Rating", @"")];
    sortPickerView = [GKActionSheetPicker stringPickerWithItems:sortArr selectCallback:^(id selected) {
        [self sortBookmark:selected];
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
        self.topConstraint.constant = 70.f;
    } else {
        if ([self isAfteriPhoneX]) {
            self.topSearchConstraint.constant = 44.f;
            self.topConstraint.constant = 93.f;
        } else {
            self.topSearchConstraint.constant = 20.f;
            self.topConstraint.constant = 70.f;
        }
    }
    [self updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.sortLabel setText:NSLocalizedString(@"Complete Date", @"")];
    
    self.managedObjectContext = nil;
    self.quoteManagedObjectContext = nil;
    self.fetchedResultsController = nil;
    self.quoteFetchedResultsController = nil;
    
    [coreData coreDataInitialize];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.quoteFetchedResultsController = coreData.quoteFetchedResultsController;
    self.quoteFetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
    self.quoteManagedObjectContext = coreData.quoteManagedObjectContext;
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// resize image with fixed width
- (UIImage *)resizeImageWithWidth:(UIImage *)image targetWidth:(CGFloat)targetWidth {
    CGFloat scaleFactor = targetWidth / image.size.width;
    CGFloat targetHeight = image.size.height * scaleFactor;
    CGSize targetSize = CGSizeMake(targetWidth, targetHeight);
    
    UIGraphicsBeginImageContext(targetSize);
    [image drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
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
// sort btn action
- (IBAction)sortBtnAction:(id)sender {
    [sortPickerView presentPickerOnView:self.view];
}

// Sort Bookmark CollectionView
- (void)sortBookmark:(NSString *)strSelect {
    [self.sortLabel setText:strSelect];
    
    NSString *sortKey = @"";
    BOOL isAscending = NO;
    if ([strSelect isEqualToString:NSLocalizedString(@"Complete Date", @"")]) {
        sortKey = @"completeDate";
    } else if ([strSelect isEqualToString:NSLocalizedString(@"Book Title", @"")]) {
        isAscending = YES;
        sortKey = @"title";
    } else if ([strSelect isEqualToString:NSLocalizedString(@"Rating", @"")]) {
        sortKey = @"rate";
    }
    
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

#pragma mark - Bookmark Configure
// delete Bookmark
- (void)deleteBookmark:(Book *)book indexPath:(NSIndexPath *)indexPath {
    NSFetchRequest <Quote *> *fetchRequest = Quote.fetchRequest;
    
    [self.managedObjectContext performBlock:^{
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        NSArray *quoteArr = [book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        Quote *quote = quoteArr[indexPath.item];
        
        NSError * error;
        
        NSArray * resultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if([resultArray count]) {
            [book removeQuotesObject:quote];
            
            [self.managedObjectContext save:&error];
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
    self.quoteFetchedResultsController = nil;
    
    [coreData coreDataInitialize];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.quoteFetchedResultsController = coreData.quoteFetchedResultsController;
    self.quoteFetchedResultsController.delegate = self;
    
    NSFetchRequest *request = [self.fetchedResultsController fetchRequest];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"quotes.strData contains[cd] %@", searchBar.text];
    
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sortDescriptor]];

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.collectionView reloadData];
    
    
    NSFetchRequest *qRequest = [self.quoteFetchedResultsController fetchRequest];
    NSSortDescriptor *qSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSPredicate *qPredicate = [NSPredicate predicateWithFormat:@"strData contains[cd] %@", searchBar.text];
    [qRequest setPredicate:qPredicate];
    [qRequest setSortDescriptors:@[qSortDescriptor]];
    
    NSError *qError = nil;
    if (![self.quoteFetchedResultsController performFetch:&qError]) {
        NSLog(@"Unresolved qError %@, %@", qError, [qError userInfo]);
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
    
    NSIndexPath *fetchIndexPath = [NSIndexPath indexPathForItem:indexPath.section inSection:0];
    Book *book = [self.fetchedResultsController objectAtIndexPath:fetchIndexPath];
    
    [cell.indexLabel setText:[NSString stringWithFormat:@"%ld", (indexPath.item+1)]];
    
    if (book) {
        
        NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
        NSArray *quoteArr = [book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
        
        if (isSearchBarActive) {
            NSMutableArray *modiArr = [NSMutableArray array];
            for (int i = 0; i < book.quotes.count; i++) {
                Quote *quote = quoteArr[i];
                if ([quote.strData containsString:self.searchBar.text]) {
                    [modiArr addObject:quote];
                }
            }
            quoteArr = [modiArr copy];
        }
        
        if (quoteArr && quoteArr.count > 0) {
            Quote *quote = quoteArr[indexPath.item];
            NSAttributedString *attrQuote = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)quote.data]; // nsdate -> nsattributedstring
            
            if (attrQuote && attrQuote.length > 0) {
                // get textView width
                __block CGFloat width = cell.quoteTextView.frame.size.width;
                CGFloat indexWidth = [cell.indexLabel.text boundingRectWithSize:CGSizeMake(1000, 16) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]} context:nil].size.width;
                CGFloat allWidth = 10.f + indexWidth + 1.f + 20.f + 5.f + 15.f;
                width = cell.frame.size.width - allWidth;
                
                // get textView height
                __block CGFloat height = [attrQuote boundingRectWithSize:CGSizeMake(width, 1000) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil].size.height;
                
                __block NSMutableAttributedString *fixedAttrStr;
                
                // get ONLY text view height
                CGFloat quoteHeight = 0.f;
                NSString *strQuote = attrQuote.string;
                if (strQuote && strQuote.length > 0) {
                    quoteHeight = [strQuote boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.f]} context:nil].size.height;
                    
                    if (quoteHeight > height) {
                        height = quoteHeight;
                    }
                }
                
                [attrQuote enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attrQuote.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
                    if (![value isKindOfClass:[NSTextAttachment class]]) {
                        return;
                    }
                    
                    NSTextAttachment *attachment = (NSTextAttachment*)value;
                    
                    // get image height
                    CGFloat origHeight = attachment.image.size.height;
                    
                    // get TEXT height
                    CGFloat strHeight = 0.f;
                    NSString *strAttr = attrQuote.string;
                    if (strAttr && strAttr.length > 0) {
                        strHeight = [strAttr boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.f]} context:nil].size.height;
                    }
                    
                    // get resized image height
                    CGFloat reHeight = (width / attachment.image.size.width) * origHeight;
                    
                    if (reHeight > origHeight) {
                        height += (reHeight - origHeight);
                    }
                    
                    // height = image height + text height
                    height = reHeight + strHeight;
                    
                    // set resized image bounds
                    attachment.bounds = CGRectMake(0, 0, width, reHeight);
                    
                    // arrange attachment (text & image or image & text)
                    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:strAttr attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.f], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"333333"]}];
                    if (range.location >=  strAttr.length-1) {
                        NSAttributedString *attrImg = [NSAttributedString attributedStringWithAttachment:attachment];
                        fixedAttrStr = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
                        [fixedAttrStr appendAttributedString:attrImg];
                    } else if (range.location == 0) {
                        NSAttributedString *attachAttr = [NSAttributedString attributedStringWithAttachment:attachment];
                        fixedAttrStr = [[NSMutableAttributedString alloc] initWithAttributedString:attachAttr];
                        [fixedAttrStr appendAttributedString:attrStr];
                    }
                    
                }];
                
                if (fixedAttrStr && fixedAttrStr.length != 0) {
                    attrQuote = fixedAttrStr;
                }
                
                [cell.quoteTextView setAttributedText:attrQuote];
                cell.quoteTextViewHeightConst.constant = height;
                cell.quoteTextView.contentSize = CGSizeMake(width, height);
                [cell.quoteTextView setContentInset:UIEdgeInsetsZero];
                cell.quoteTextView.textContainerInset = UIEdgeInsetsZero;
                cell.quoteTextView.textContainer.lineFragmentPadding = 0;
                
                [cell updateConstraints];
            }
        }
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    BookMarkHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"BookMarkHeaderCollectionReusableView" forIndexPath:indexPath];
    
    NSIndexPath *fetchIndexPath = [NSIndexPath indexPathForItem:indexPath.section inSection:0];
    Book *book = [self.fetchedResultsController objectAtIndexPath:fetchIndexPath];
    
    [headerView.titleLabel setText:book.title];
    [headerView.bmCountLabel setText:[NSString stringWithFormat:@"%ld", book.quotes.count]];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
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

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger count = 0;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:section inSection:0];
    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (isSearchBarActive) {
        NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
        NSArray *quoteArr = [book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
        for (int i = 0; i < book.quotes.count; i++) {
            Quote *quote = quoteArr[i];
            if ([quote.strData containsString:self.searchBar.text]) {
                count += 1;
            }
        }
    }
    else {
        count = book.quotes.count;
    }
    return count;
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
    NSIndexPath *fetchIndexPath = [NSIndexPath indexPathForItem:indexPath.section inSection:0];
    Book *book = [self.fetchedResultsController objectAtIndexPath:fetchIndexPath];

    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    NSArray *quoteArr = [book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
    Quote *quote;
    
    if (isSearchBarActive) {
        NSMutableArray *modiArr = [NSMutableArray array];
        for (int i = 0; i < book.quotes.count; i++) {
            Quote *quote = quoteArr[i];
            if ([quote.strData containsString:self.searchBar.text]) {
                [modiArr addObject:quote];
            }
        }
        quoteArr = [modiArr copy];
        
        isSearchBarActive = NO;
        [self.searchBar setText:@""];
    }
    
    if (quoteArr.count > 0 && quoteArr) {
        quote = quoteArr[indexPath.item];
    }
    
    BookmarkDetailViewController *detailVC = [[BookmarkDetailViewController alloc] init];
    detailVC.book = book;
    detailVC.quoteIndex = quote.index;
    [detailVC setBookmarkDetailCompositionHandler:book bookmarkDeleteCompleted:^(NSIndexPath *indexPath) {
        [self deleteBookmark:book indexPath:indexPath];
    }];
    [self pushController:detailVC animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat textWidth = self.collectionView.frame.size.width;
    CGFloat width = self.collectionView.frame.size.width;
    __block CGFloat height = 0.f;
    NSIndexPath *fetchIndexPath = [NSIndexPath indexPathForItem:indexPath.section inSection:0];
    Book *book = [self.fetchedResultsController objectAtIndexPath:fetchIndexPath];
    
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    NSArray *quoteArr = [book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
    
    if (isSearchBarActive) {
        NSMutableArray *modiArr = [NSMutableArray array];
        for (int i = 0; i < book.quotes.count; i++) {
            Quote *quote = quoteArr[i];
            if ([quote.strData containsString:self.searchBar.text]) {
                [modiArr addObject:quote];
            }
        }
        quoteArr = [modiArr copy];
    }

    if (quoteArr && quoteArr.count > 0) {
        
        // get textView width
        NSString *strIndex = [NSString stringWithFormat:@"%ld", (indexPath.item+1)];
        CGFloat indexWidth = [strIndex boundingRectWithSize:CGSizeMake(1000, 16) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]} context:nil].size.width;
        CGFloat allWidth = 10.f + indexWidth + 1.f + 20.f + 5.f + 15.f;
        textWidth = width - allWidth;
        
        Quote *quote = quoteArr[indexPath.item];
        NSAttributedString *attrQuote = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)quote.data]; // nsdate -> nsattributedstring
        
        if (attrQuote && attrQuote.length > 0) {
            // get basic textView height
            height = [attrQuote boundingRectWithSize:CGSizeMake(textWidth, 1000) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil].size.height;
            
            // get ONLY text view height
            CGFloat quoteHeight = 0.f;
            NSString *strQuote = attrQuote.string;
            if (strQuote && strQuote.length > 0) {
                quoteHeight = [strQuote boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.f]} context:nil].size.height;
                
                if (quoteHeight > height) {
                    height = quoteHeight;
                }
            }
            
            [attrQuote enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attrQuote.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
                if (![value isKindOfClass:[NSTextAttachment class]]) {
                    return;
                }
                
                NSTextAttachment *attachment = (NSTextAttachment*)value;
                
                // get image height
                CGFloat origHeight = attachment.image.size.height;
                
                // get text height
                CGFloat strHeight = 0.f;
                NSString *strAttr = attrQuote.string;
                if (strAttr && strAttr.length > 0) {
                    strHeight = [strAttr boundingRectWithSize:CGSizeMake(textWidth, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.f]} context:nil].size.height;
                }
                
                // get resized image height
                CGFloat reHeight = (textWidth / attachment.image.size.width) * origHeight;
                
                if (reHeight > origHeight) {
                    height += (reHeight - origHeight);
                }
                
                // height = image height + text height
                height = reHeight + strHeight;
            }];
        }
        
        height += 20.f;
        
    }
    
    return CGSizeMake(width, height);
}

#pragma mark - Fetched results controller
- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    if (controller == self.fetchedResultsController) {
        NSLog(@"YJ << NSFetchedResultsController - controllerWillChangeContent - BookmarkViewController");
        
        self.updateBlock = [NSBlockOperation new];
        
    }
}

- (void) controller:(NSFetchedResultsController *)controller didChangeSection:(nonnull id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    __weak UICollectionView *collectionView = self.collectionView;
    
    if (controller == self.fetchedResultsController) {
        NSLog(@"YJ << NSFetchedResultsController - didChangeSection - BookmarkViewController");
        
        switch(type) {
            case NSFetchedResultsChangeInsert: {
                [self.updateBlock addExecutionBlock:^{
                    //                    [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                    [collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                }];
            }
                break;
            case NSFetchedResultsChangeDelete: {
                [self.updateBlock addExecutionBlock:^{
                    //                    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
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
    
     __weak UICollectionView *collectionView = self.collectionView;
    
    if (controller == self.fetchedResultsController) {
        NSLog(@"YJ << NSFetchedResultsController - didChangeObject - BookmarkViewController");
        
        [self.updateBlock addExecutionBlock:^{
            [collectionView reloadData];
        }];
    }
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if (controller == self.fetchedResultsController) {
        NSLog(@"YJ << NSFetchedResultsController - controllerDidChangeContent - BookmarkViewController");
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [controller sections][0];
        NSInteger bookCount = [sectionInfo numberOfObjects];
        NSInteger bmCount = 0;
        if (bookCount > 0) {
            for (int i = 0; i < bookCount; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
                bmCount = book.quotes.count;
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
