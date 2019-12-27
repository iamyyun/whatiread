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

@interface BookDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate> {
    NSArray *quoteArr;
    
    CoreDataAccess *coreData;

    CGFloat lastContentOffset;
}

@end

@implementation BookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:NO];
    
    // localize language
    [self.authorLangLabel setText:NSLocalizedString(@"Author", @"")];
    [self.publisherLangLabel setText:NSLocalizedString(@"Publisher", @"")];
    [self.pubDateLangLabel setText:NSLocalizedString(@"Published Date", @"")];
    [self.startDateLangLabel setText:NSLocalizedString(@"Start Date", @"")];
    [self.compDateLangLabel setText:NSLocalizedString(@"Complete Date", @"")];
    [self.rateLangLabel setText:NSLocalizedString(@"Rating", @"")];
    [self.bmLangLabel setText:NSLocalizedString(@"Bookmark", @"")];
    [self.noBmLangLabel setText:NSLocalizedString(@"There is no bookmark.", @"")];
    [self.addBmBtn setTitle:NSLocalizedString(@"Add Bookmark", @"") forState:UIControlStateNormal];
    [self.editBsBtn setTitle:NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
    [self.deleteBsBtn setTitle:NSLocalizedString(@"Delete", @"") forState:UIControlStateNormal];
    
    // Initialize CoreData
    coreData = [CoreDataAccess sharedInstance];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
    
    if (self.book) {
        // quote showing
        NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
        quoteArr = [self.book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
        
        if (quoteArr && quoteArr.count > 0) {
            [self.collectionView setHidden:NO];
            [self.emptyView setHidden:YES];
        } else {
            [self.collectionView setHidden:YES];
            [self.emptyView setHidden:NO];
        }
        
        // checking isSearching flag, cover img hidden
        BOOL isSearch = self.book.isSearchMode;
        if (isSearch) {
            NSData *imgData = self.book.coverImg;
            if (imgData) {
                [self.coverImgView setHidden:NO];
                self.coverImgWidthConst.constant = 90.f;
                self.coverImgLeadingConst.constant = 15.f;
            } else {
                [self.coverImgView setHidden:YES];
                self.coverImgWidthConst.constant = 0.f;
                self.coverImgLeadingConst.constant = 5.f;
            }
        } else {
            [self.coverImgView setHidden:YES];
            self.coverImgWidthConst.constant = 0.f;
            self.coverImgLeadingConst.constant = 5.f;
        }
    }
    
    [self.collectionView setAllowsSelection:YES];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BookDetailCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"BookDetailCollectionViewCell"];
    
    [self.rateView setStarFillColor:[UIColor colorWithHexString:@"F0C330"]];
    [self.rateView setStarNormalColor:[UIColor lightGrayColor]];
    [self.rateView setCanRate:NO];
    [self.rateView setStarSize:20.f];
    [self.rateView setStep:0.5f];
    
    // top Constraint
    if ([self isiPad]) {
        self.topConstraint.constant = 64.f;
    } else {
        if ([self isAfteriPhoneX]) {
            self.topConstraint.constant = 88.f;
        } else {
            self.topConstraint.constant = 64.f;
        }
    }
    [self updateViewConstraints];
    
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

- (void)dataInitialize {
    if (self.book) {
        [self setNaviBarType:BAR_BACK title:NSLocalizedString(@"Book Information", @"") image:nil];
        
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
                if (isResult) {
                    [self.view makeToast:NSLocalizedString(@"Succeeded to modify book", @"")];
                } else {
                    [self.view makeToast:NSLocalizedString(@"Failed to modify book", @"")];
                }
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
            
            [self dataInitialize];
            
            [self modifyBook:self.book bookDic:bookDic completed:^(BOOL isResult) {
                if (isResult) {
                    [self.view makeToast:NSLocalizedString(@"Succeeded to modify book", @"")];
                } else {
                    [self.view makeToast:NSLocalizedString(@"Failed to modify book", @"")];
                }
            }];
        }];
        [self pushController:writeVC animated:YES];
    }
}

// delete bookshelf
- (IBAction)deleteBookShelfBtnAction:(id)sender {
    
    if (quoteArr && quoteArr.count > 0) {
//        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        [appDelegate.alertWindow makeKeyAndVisible];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"You can not delete the book because bookmarks are registered. Please delete bookmarks and delete the book.", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [appDelegate.alertWindow setHidden:YES];
        }];
        [alert addAction:okAction];
        
        [self presentController:alert animated:YES];
//        [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        
    } else {
//        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        [appDelegate.alertWindow makeKeyAndVisible];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete", @"") message:NSLocalizedString(@"Do you really want to delete?", @"") preferredStyle:UIAlertControllerStyleActionSheet];
        
        NSString *strFirst = NSLocalizedString(@"Deleting", @"");
        NSString *strSecond = NSLocalizedString(@"Cancel", @"");
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//            [appDelegate.alertWindow setHidden:YES];
            
            [self deleteBook];
        }];
        UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [appDelegate.alertWindow setHidden:YES];
            
            [self dismissController:alert animated:YES];
        }];
        
        [alert addAction:firstAction];
        [alert addAction:secondAction];
        [self presentController:alert animated:YES];
//        [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
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
            if (isResult) {
                [self.view makeToast:NSLocalizedString(@"Succeeded to add bookmark", @"")];
            } else {
                [self.view makeToast:NSLocalizedString(@"Failed to add bookmark", @"")];
            }
        }];
        
    } bookmarkModifyCompleted:nil];
    
    [self pushController:addVC animated:YES];
}

// create bookmark
- (void)createBookmark:(Book *)book qDic:(NSDictionary *)qDic completed:(void (^)(BOOL isResult))completed {
    NSInteger quoteCount = book.quotes.count;
    NSInteger quoteIndex = 0;
    
    // get LAST QUOTE
    if (quoteCount > 0) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        NSArray *quoteArr = [book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        Quote *lastQuote = quoteArr[quoteCount-1];
        quoteIndex = lastQuote.index+1;
    } else {
        quoteIndex = 1;
    }
    
    NSAttributedString *attrStr = [qDic objectForKey:@"mQuote"];
    NSData *attrData = [NSKeyedArchiver archivedDataWithRootObject:attrStr]; // nsdate -> nsattributedstring
    
    Quote *quote = [[Quote alloc] initWithContext:self.managedObjectContext];
    quote.index = quoteIndex;
    quote.createDate = [NSDate date];
    quote.modifyDate = [NSDate date];
    quote.data = attrData;
    quote.strData = attrStr.string;
    
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
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"createDate = %@", book.createDate]];
        
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
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"createDate = %@", self.book.createDate]];
        
        NSError * error;
        
        NSArray * resultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if([resultArray count]) {
            [self.managedObjectContext deleteObject:[resultArray lastObject]];
            [self.managedObjectContext save:&error];
            
            if (!error) {
                [self popController:YES];
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
        NSAttributedString *attrQuote = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)quote.data]; // nsdate -> nsattributedstring
        
        [cell.bMarkCountLabel setText:[NSString stringWithFormat:@"%ld", indexPath.item+1]];
        
        if (attrQuote && attrQuote.length > 0) {
            
            // get textView width
            __block CGFloat width = cell.quoteTextView.frame.size.width;
            width = cell.frame.size.width - 30.f;
        
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
//            [cell.quoteTextView.textStorage setAttributedString:attrQuote];
            cell.quoteTextViewHeightConst.constant = height;
            cell.quoteTextView.contentSize = CGSizeMake(width, height);
            [cell.quoteTextView setContentInset:UIEdgeInsetsZero];
            cell.quoteTextView.textContainerInset = UIEdgeInsetsZero;
            cell.quoteTextView.textContainer.lineFragmentPadding = 0;
            
            [cell updateConstraints];
        }
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
    // get Quote
    Quote *quote = quoteArr[indexPath.item];
    
    BookmarkDetailViewController *detailVC = [[BookmarkDetailViewController alloc] init];
    detailVC.book = self.book;
    detailVC.indexPath = indexPath;
    detailVC.quoteIndex = quote.index;
    [detailVC setBookmarkDetailCompositionHandler:self.book bookmarkDeleteCompleted:^(NSIndexPath *indexPath) {
        [self deleteBookmark:self.book indexPath:indexPath];
    }];
    [self pushController:detailVC animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat textWidth = self.collectionView.frame.size.width;
    CGFloat width = self.collectionView.frame.size.width;
    __block CGFloat height = 0.f;
    
    if (quoteArr && quoteArr.count > 0) {
        
        // get textView width
        textWidth = width - 30.f;
        
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
            
            [attrQuote enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attrQuote.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
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
        
        height += 40.f;
    }
    
    return CGSizeMake(width, height);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (lastContentOffset > scrollView.contentOffset.y) {
        // scrolling UP
    } else if (lastContentOffset < scrollView.contentOffset.y) {
        // scrolling DOWN
        
        CGFloat collHeight = self.collectionView.frame.size.height;
        CGFloat contentHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
        if (contentHeight <= (collHeight + 170)) {
            
        } else {
            [UIView transitionWithView:self.infoView duration:0.1 options:UIViewAnimationOptionTransitionNone animations:^(void){
                [self.infoView setHidden:YES];
            } completion:nil];
            self.infoViewHeightConst.constant = 0.f;
            
            [self updateViewConstraints];
        }
    }
    lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y <= 0) {
        // scroll til top
        
        [UIView transitionWithView:self.infoView duration:0.1 options:UIViewAnimationOptionTransitionNone animations:^(void){
            [self.infoView setHidden:NO];
        } completion:nil];
        self.infoViewHeightConst.constant = 159.f;
        
        [self updateViewConstraints];
    }
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        // scroll til end
        
        CGFloat collHeight = self.collectionView.frame.size.height;
        CGFloat contentHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
        if (contentHeight <= (collHeight + 170)) {
            
        } else {
            [UIView transitionWithView:self.infoView duration:0.1 options:UIViewAnimationOptionTransitionNone animations:^(void){
                [self.infoView setHidden:YES];
            } completion:nil];
            self.infoViewHeightConst.constant = 0.f;
            
            [self updateViewConstraints];
        }
    }
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
        
        __weak UICollectionView *collectionView = self.collectionView;
        
        [self.updateBlock addExecutionBlock:^{
            [collectionView reloadData];
        }];
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
