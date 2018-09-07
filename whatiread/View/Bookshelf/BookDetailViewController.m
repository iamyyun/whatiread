//
//  BookDetailViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 7. 5..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "BookDetailViewController.h"
#import "BookDetailCollectionViewCell.h"
#import "BookShelfViewController.h"
#import "AddBookViewController.h"
#import "WriteBookViewController.h"
#import "AddBookmarkViewController.h"
#import "BookmarkDetailViewController.h"

@interface BookDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource> {
    NSArray *quoteArr;
    
    CoreDataAccess *coreData;
}

@end

@implementation BookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:NO];
    
    coreData = [CoreDataAccess sharedInstance];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
    
    if (self.book) {
        NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
        quoteArr = [self.book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
        
        if (quoteArr && quoteArr.count > 0) {
            [self.collectionView setHidden:NO];
            [self.emptyView setHidden:YES];
        } else {
            [self.collectionView setHidden:YES];
            [self.emptyView setHidden:NO];
        }
    }
    
    [self.collectionView setAllowsSelection:YES];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BookDetailCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"BookDetailCollectionViewCell"];
    
    [self.rateView setStarFillColor:[UIColor colorWithHexString:@"F0C330"]];
    [self.rateView setStarNormalColor:[UIColor lightGrayColor]];
    [self.rateView setCanRate:NO];
    [self.rateView setStarSize:20.f];
    [self.rateView setStep:0.5f];
    
    [self dataInitialize];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.managedObjectContext = nil;
    self.fetchedResultsController = nil;
    
    [coreData coreDataInitialize];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dataInitialize {
    if (self.book) {
        [self setNaviBarType:BAR_BACK title:@"책 정보" image:nil];
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy.MM.dd"];
        
        UIImage *image = [UIImage imageWithData:self.book.coverImg];
        
        NSString *strTitle = self.book.title;
        CGFloat height = [strTitle boundingRectWithSize:CGSizeMake(self.titleLabel.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]} context:nil].size.height;
        self.titleLabelHeightConst.constant = height;
        [self.titleLabel setText:strTitle];
        [self.authorLabel setText:self.book.author];
        [self.publisherLabel setText:self.book.publisher];
        [self.pubDateLabel setText:[format stringFromDate:self.book.publishDate]];
        [self.startDateLabel setText:[format stringFromDate:self.book.startDate]];
        [self.compDateLabel setText:[format stringFromDate:self.book.completeDate]];
        [self.rateView setRating:self.book.rate];
        
        if (image) {
            [self.coverImgView setImage:image];
        }
        
        [self.bmCountLabel setText:[NSString stringWithFormat:@"%ld", self.book.quotes.count]];
        
        [self.collectionView reloadData];
        
        [self.view updateConstraints];
    }
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

#pragma mark - Navigation Bar Actions
- (void)leftBarBtnClick:(id)sender
{
    [self popController:YES];
}

#pragma mark - Actions
// add bookmark
- (IBAction)addBookmarkBtnAction:(id)sender {
    
     [self bookmarkConfigure:self.book ocrText:nil];
}

// edit bookshelf
- (IBAction)EditBookShelfBtnAction:(id)sender {
    
    if (self.book.isSearchMode) {
        AddBookViewController *addVC = [[AddBookViewController alloc] init];
        addVC.book = self.book;
        addVC.isModifyMode = YES;
        [addVC setAddBookCompositionHandler:nil addBookCreateCompleted:nil addBookModifyCompleted:^(NSDictionary *bookDic){
            self.book.title = [bookDic objectForKey:@"bTitle"];
            self.book.author = [bookDic objectForKey:@"bAuthor"];
            self.book.publisher = [bookDic objectForKey:@"bPublisher"];
            self.book.publishDate = [bookDic objectForKey:@"bPubDate"];
            self.book.startDate = [bookDic objectForKey:@"bStartDate"];
            self.book.completeDate = [bookDic objectForKey:@"bCompleteDate"];
            self.book.rate = [[bookDic objectForKey:@"bRate"] floatValue];
            
            [self dataInitialize];
            
            [self modifyBook:self.book bookDic:bookDic completed:^(BOOL isResult) {
                
            }];
        }];
        [self pushController:addVC animated:YES];
    }
    else {
        WriteBookViewController *writeVC = [[WriteBookViewController alloc] init];
        writeVC.book = self.book;
        writeVC.isModifyMode = YES;
        [writeVC setWriteBookCompositionHandler:self.book writeBookCreateCompleted:nil writeBookModifyCompleted:^(NSDictionary *bookDic) {
            self.book.title = [bookDic objectForKey:@"bTitle"];
            self.book.author = [bookDic objectForKey:@"bAuthor"];
            self.book.publisher = [bookDic objectForKey:@"bPublisher"];
            self.book.publishDate = [bookDic objectForKey:@"bPubDate"];
            self.book.startDate = [bookDic objectForKey:@"bStartDate"];
            self.book.completeDate = [bookDic objectForKey:@"bCompleteDate"];
            self.book.rate = [[bookDic objectForKey:@"bRate"] floatValue];
            //            self.book.quoteImg = bookImage;
            [self dataInitialize];
            
            [self modifyBook:self.book bookDic:bookDic completed:^(BOOL isResult) {
                
            }];
        }];
        [self pushController:writeVC animated:YES];
    }
}

// delete bookshelf
- (IBAction)deleteBookShelfBtnAction:(id)sender {
    if (quoteArr && quoteArr.count > 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"해당 책 정보에 책갈피가 등록되어 있어 책 정보를 삭제 할 수 없습니다. 책갈피 삭제 후 삭제 해 주시기 바랍니다." message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [alert addAction:okAction];
        [self presentController:alert animated:YES];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete", @"") message:NSLocalizedString(@"Do you really want to delete?", @"") preferredStyle:UIAlertControllerStyleActionSheet];
        
        NSString *strFirst = NSLocalizedString(@"Deleting", @"");
        NSString *strSecond = NSLocalizedString(@"Cancel", @"");
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self deleteBook];
        }];
        UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissController:alert animated:YES];
        }];
        
        [alert addAction:firstAction];
        [alert addAction:secondAction];
        [self presentController:alert animated:YES];
    }
}

#pragma mark - Bookmark Configure
- (void)bookmarkConfigure:(Book *)book ocrText:(NSString *)ocrText;
{
    AddBookmarkViewController *addVC = [[AddBookmarkViewController alloc] init];
    addVC.isModifyMode = NO;
    if (ocrText && ocrText.length > 0) {
        addVC.strOcrText = ocrText;
    }
    [addVC setBookmarkCompositionHandler:self.book bookmarkCreateCompleted:^(NSAttributedString *attrQuote) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:attrQuote forKey:@"mQuote"];
        
        [self createBookmark:self.book qDic:dic completed:^(BOOL isResult) {
            
        }];
        
        NSLog(@"YJ << quote : %@", attrQuote);
    } bookmarkModifyCompleted:nil];
    [self pushController:addVC animated:YES];
}

// create bookmark
- (void)createBookmark:(Book *)book qDic:(NSDictionary *)qDic completed:(void (^)(BOOL isResult))completed {
    NSInteger quoteCount = book.quotes.count;
    
    NSData *imgData = UIImagePNGRepresentation([qDic objectForKey:@"mImage"]);
    NSAttributedString *attrStr = [qDic objectForKey:@"mQuote"];
    
    Quote *quote = [[Quote alloc] initWithContext:self.managedObjectContext];
    quote.index = quoteCount;
    quote.date = [NSDate date];
    quote.data = attrStr;
    quote.strData = attrStr.string;
    quote.image = imgData;
    
    [book addQuotesObject:quote];
    
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
    
    [self.collectionView reloadData];
}

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
            
//            if (!error) {
//                [self popController:YES];
//            }
        }
    }];
}

// modify book
- (void)modifyBook:(Book *)book bookDic:(NSDictionary *)bookDic completed:(void (^)(BOOL isResult))completed {

    NSFetchRequest <Book *> *fetchRequest = Book.fetchRequest;
    
    NSDate *now = [[NSDate alloc] init];
    
    [self.managedObjectContext performBlock:^{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completeDate" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"modifyDate = %@", book.modifyDate]];
        
        NSError * error;
        
        NSArray * resultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if([resultArray count]) {
            Book *book = [resultArray lastObject];
            if ([bookDic objectForKey:@"bTitle"]) {
                book.title = [bookDic objectForKey:@"bTitle"];
            } else {
                book.title = @"";
            }
            
            if ([bookDic objectForKey:@"bAuthor"]) {
                book.author = [bookDic objectForKey:@"bAuthor"];
            } else {
                book.author = @"";
            }
            
            if ([bookDic objectForKey:@"bPublisher"]) {
                book.publisher = [bookDic objectForKey:@"bPublisher"];
            } else {
                book.publisher = @"";
            }
            
            if ([bookDic objectForKey:@"bPubDate"]) {
                book.publishDate = [bookDic objectForKey:@"bPubDate"];
            } else {
                book.publishDate = [NSDate date];
            }
            
            if ([bookDic objectForKey:@"bStartDate"]) {
                book.startDate = [bookDic objectForKey:@"bStartDate"];
            } else {
                book.startDate = [NSDate date];
            }
            
            if ([bookDic objectForKey:@"bCompleteDate"]) {
                book.completeDate = [bookDic objectForKey:@"bCompleteDate"];
            } else {
                book.completeDate = [NSDate date];
            }
            
            if ([bookDic objectForKey:@"bRate"]) {
                book.rate = [[bookDic objectForKey:@"bRate"] floatValue];
            } else {
                book.rate = 0.f;
            }
            
            if ([bookDic objectForKey:@"bCoverImg"]) {
                NSData *imageData = UIImagePNGRepresentation([bookDic objectForKey:@"bCoverImg"]);
                book.coverImg = imageData;
            } else {
                book.coverImg = nil;
            }
            
            book.modifyDate = now;
            
            [self.managedObjectContext save:&error];
            
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

// delete Book
- (void)deleteBook {

    NSFetchRequest <Book *> *fetchRequest = Book.fetchRequest;
    
    [self.managedObjectContext performBlock:^{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completeDate" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"modifyDate = %@", self.book.modifyDate]];
        
        NSError * error;
        
        NSArray * resultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if([resultArray count]) {
            [self.managedObjectContext deleteObject:[resultArray lastObject]];
            [self.managedObjectContext save:&error];
            
            if (!error) {
                [self popController:YES];
//                [self performSelector:@selector(leftBarBtnClick:) withObject:nil afterDelay:0.5];
            }
        }
    }];
}

#pragma mark - UICollectionViewDataSource
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"BookDetailCollectionViewCell";
    BookDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
    }
    
    if(quoteArr && quoteArr.count > 0) {
        Quote *quote = quoteArr[indexPath.item];
        NSAttributedString *attrQuote = (NSAttributedString *)quote.data;
        
        if (attrQuote && attrQuote.length > 0) {
        
           __block CGFloat height = [attrQuote boundingRectWithSize:CGSizeMake(cell.quoteTextView.frame.size.width, 1000) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil].size.height;
            
            NSLog(@"YJ << cell height : %f", height);
            NSLog(@"YJ << cell width : %f", cell.quoteTextView.frame.size.width);
            
            [attrQuote enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attrQuote.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
                if (![value isKindOfClass:[NSTextAttachment class]]) {
                    return;
                }
                NSTextAttachment *attachment = (NSTextAttachment*)value;
                CGFloat origHeight = attachment.image.size.height;
                NSLog(@"YJ << origin height : %f", origHeight);
                NSLog(@"YJ << origin width : %f", attachment.image.size.width);
//                CGFloat reHeight = (attachment.image.size.width / cell.quoteTextView.frame.size.width) * origHeight;
                CGFloat reHeight = (cell.quoteTextView.frame.size.width / attachment.image.size.width) * origHeight;
                attachment.bounds = CGRectMake(0, 0, cell.quoteTextView.frame.size.width, reHeight);
                
                if (reHeight > origHeight) {
                    height += (reHeight - origHeight);
                }
                
                NSLog(@"YJ << re height : %f", reHeight);
                NSLog(@"YJ << final width : %f", cell.quoteTextView.frame.size.width);
            }];
        
            NSLog(@"YJ << final height : %f", height);
            NSLog(@"------------------------------------------------------");
            
//            [cell.quoteTextView setAttributedText:attrQuote];
            [cell.quoteTextView.textStorage setAttributedString:attrQuote];
//            [cell.quoteTextView.textStorage insertAttributedString:attrQuote atIndex:0];
            cell.quoteTextViewHeightConst.constant = height;
            cell.quoteTextView.contentSize = CGSizeMake(cell.quoteTextView.frame.size.width, height);
            [cell.quoteTextView setContentInset:UIEdgeInsetsZero];
            cell.quoteTextView.textContainerInset = UIEdgeInsetsZero;
            cell.quoteTextView.textContainer.lineFragmentPadding = 0;
            
        }

        [cell.bMarkCountLabel setText:[NSString stringWithFormat:@"%ld", indexPath.item+1]];
    }
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger bmCount = 0;
    if (self.book) {
        bmCount = self.book.quotes.count;
    }
    
    return bmCount;
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
    BookmarkDetailViewController *detailVC = [[BookmarkDetailViewController alloc] init];
    NSLog(@"YJ << book quotes : %d", self.book.quotes.count);
    detailVC.book = self.book;
    detailVC.indexPath = indexPath;
    [detailVC setBookmarkDetailCompositionHandler:self.book bookmarkDeleteCompleted:^(NSIndexPath *indexPath) {
        [self deleteBookmark:self.book indexPath:indexPath];
    }];
    [self pushController:detailVC animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGSize cellSize = CGSizeMake(width, 50);
    
    if (quoteArr && quoteArr.count > 0) {
        
        Quote *quote = quoteArr[indexPath.item];
        NSAttributedString *attrQuote = (NSAttributedString *)quote.data;
        
        if (attrQuote && attrQuote.length > 0) {
            
            __block CGFloat height = [attrQuote boundingRectWithSize:CGSizeMake(width-30, 1000) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil].size.height;
            
            [attrQuote enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attrQuote.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
                if (![value isKindOfClass:[NSTextAttachment class]]) {
                    return;
                }
    
                NSTextAttachment *attachment = (NSTextAttachment*)value;
                CGFloat origHeight = attachment.image.size.height;
                CGFloat reHeight = ((width-30) / attachment.image.size.width) * origHeight;
//                CGFloat reHeight = (attachment.image.size.width / (width-30)) * origHeight;
                
                if (reHeight > origHeight) {
                    height += (reHeight - origHeight);
                }
                height  += 5.f;
            }];
            
            NSLog(@"YJ << item textview size height : %f", height);
            
            cellSize = CGSizeMake(width, (30.f + 11.f + height));
        }
        
        NSLog(@"YJ << item cell size width : %f", cellSize.width);
        NSLog(@"YJ << item cell size height : %f", cellSize.height);
        NSLog(@"===================================================");
    }
    return cellSize;
}

#pragma mark - FetchedResultsController Delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (controller == self.fetchedResultsController) {
        NSLog(@"YJ << NSFetchedResultsController - controllerWillChangeContent - BookDetailViewController");
        
        self.updateBlock = [NSBlockOperation new];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    if (controller == self.fetchedResultsController) {
        NSLog(@"YJ << NSFetchedResultsController - didChangeSection - BookDetailViewController");
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
}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(nonnull id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    
    if (controller == self.fetchedResultsController) {
        NSLog(@"YJ << NSFetchedResultsController - didChangeObject - BookDetailViewController");
        NSLog(@"YJ << section : %ld", indexPath.section);
        NSLog(@"YJ << item : %ld", indexPath.item);
        NSLog(@"YJ << new section : %ld", newIndexPath.section);
        NSLog(@"YJ << new item : %ld", newIndexPath.item);
        
        __weak UICollectionView *collectionView = self.collectionView;
        
        [self.updateBlock addExecutionBlock:^{
            [collectionView reloadData];
        }];
        
//        switch(type) {
//            case NSFetchedResultsChangeInsert: {
//                [self.updateBlock addExecutionBlock:^{
//                    //                     [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
//                    [collectionView reloadItemsAtIndexPaths:@[newIndexPath]];
//                }];
//                break;
//            }
//            case NSFetchedResultsChangeDelete: {
//                [self.updateBlock addExecutionBlock:^{
//                    [collectionView reloadData];
////                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
//                }];
//                break;
//            }
//            case NSFetchedResultsChangeUpdate: {
//                [self.updateBlock addExecutionBlock:^{
//                    [collectionView reloadData];
////                    [collectionView reloadItemsAtIndexPaths:@[newIndexPath]];
//                }];
//                break;
//            }
//            case NSFetchedResultsChangeMove: {
//                [self.updateBlock addExecutionBlock:^{
//                    [collectionView reloadData];
////                    [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
////                    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
//                }];
//                break;
//            }
//        }
    }
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (controller == self.fetchedResultsController) {
        NSLog(@"YJ << NSFetchedResultsController - controllerDidChangeContent - BookDetailViewController");
        
        NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
        quoteArr = [self.book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
        
        if (quoteArr && quoteArr.count > 0) {
            [self.collectionView setHidden:NO];
            [self.emptyView setHidden:YES];
        } else {
            [self.collectionView setHidden:YES];
            [self.emptyView setHidden:NO];
        }
        
        [self.bmCountLabel setText:[NSString stringWithFormat:@"%ld", self.book.quotes.count]];
        [self.collectionView reloadData];
        
        [self.collectionView performBatchUpdates:^{
            [[NSOperationQueue currentQueue] addOperation:self.updateBlock];
        } completion:^(BOOL finished) {
            [self.collectionView reloadData];
        }];
    }
}

@end
