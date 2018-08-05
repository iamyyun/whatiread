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
#import "TOCropViewController.h"
#import <Photos/Photos.h>
#import <TesseractOCR/TesseractOCR.h>

@interface BookDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate, G8TesseractDelegate> {
    NSArray *quoteArr;
    
    CoreDataAccess *coreData;
    
    BOOL isOcrActive;
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
        [self.coverImgView setImage:image];
        
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *strFirst = @"직접 입력";
    NSString *strSecond = @"사진 보관함";
    NSString *strThird = @"사진 찍기";
    NSString *strFourth = @"텍스트 추출";
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self bookmarkConfigure:self.book ocrText:nil];
    }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [self bookConfigure:nil indexPath:nil isModifyMode:NO];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        isOcrActive = NO;
        
        [self presentController:picker animated:YES];
    }];
    UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:strThird style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        isOcrActive = NO;

        [self presentController:picker animated:YES];
    }];
    UIAlertAction *fourthAction = [UIAlertAction actionWithTitle:strFourth style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        isOcrActive = YES;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"텍스트 추출" message:@"텍스트 추출을 진행할 파일의 출처를 선택해 주세요." preferredStyle:UIAlertControllerStyleAlert];

        NSString *strCamera = @"Camera";
        NSString *strAlbum = @"Album";
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:strCamera style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;

            [self presentController:picker animated:YES];
        }];
        UIAlertAction *albumAction = [UIAlertAction actionWithTitle:strAlbum style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

            [self presentController:picker animated:YES];
        }];

        [alert addAction:cameraAction];
        [alert addAction:albumAction];
        [self presentController:alert animated:YES];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:thirdAction];
    [alert addAction:fourthAction];
    [alert addAction:cancelAction];
    [self presentController:alert animated:YES];
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
            
            [self modifyBook:self.book bookDic:bookDic indexPath:self.indexPath completed:^(BOOL isResult) {
                
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
            
            [self modifyBook:self.book bookDic:bookDic indexPath:self.indexPath completed:^(BOOL isResult) {
                
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
            [self deleteBook:self.indexPath];
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
    [addVC setBookmarkCompositionHandler:self.book bookmarkCreateCompleted:^(NSString *strQuote) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:strQuote forKey:@"mQuote"];
        
        [self createBookmark:self.book qDic:dic completed:^(BOOL isResult) {
            
        }];
        
        NSLog(@"YJ << quote : %@", strQuote);
    }];
    [self pushController:addVC animated:YES];
}

// create bookmark
- (void)createBookmark:(Book *)book qDic:(NSDictionary *)qDic completed:(void (^)(BOOL isResult))completed {
    NSInteger quoteCount = book.quotes.count;
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    NSData *imgData = UIImagePNGRepresentation([qDic objectForKey:@"mImage"]);
    
    Quote *quote = [[Quote alloc] initWithContext:context];
    quote.index = quoteCount;
    quote.date = [NSDate date];
    quote.data = [qDic objectForKey:@"mQuote"];
    quote.image = imgData;
    
    [book addQuotesObject:quote];
    
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
    
    [self.collectionView reloadData];
}

// modify bookmark
- (void)modifyBook:(Book *)book bookDic:(NSDictionary *)bookDic indexPath:(NSIndexPath *)indexPath completed:(void (^)(BOOL isResult))completed {
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
            
            if (!error) {
                [self popController:YES];
            }
        }
    }];
}

#pragma mark - UIImagePickerViewController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *chosenImg = info[UIImagePickerControllerOriginalImage];
    [self dismissController:picker animated:NO];
    
    TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:chosenImg];
    cropViewController.delegate = self;
    [self presentController:cropViewController animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissController:picker animated:YES];
}

#pragma mark - TOCropViewController Delegate
- (void)cropViewController:(TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled {
    [self dismissController:cropViewController animated:YES];
}

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    UIImage *resultImage = image;
    [self dismissController:cropViewController animated:YES];
    
    [self savePhoto:resultImage];
    
    if (isOcrActive) {
        
        G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"kor+eng"];
        tesseract.delegate = self;
        //        tesseract.charWhitelist = @"0123456789";
        tesseract.image = [image g8_blackAndWhite];
        //        tessract.maximumRecognitionTime = 2.0;
        [tesseract recognize];
        
        NSLog(@"tesseract recognized text : %@", [tesseract recognizedText]);
        NSString *strOcr = [tesseract recognizedText];
//        if ([tesseract recognizedText] && [tesseract recognizedText].length > 0) {
//            [IndicatorUtil stopProcessIndicator];
//        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"텍스트 추출" message:strOcr preferredStyle:UIAlertControllerStyleAlert];
        
        NSString *strConfirm = NSLocalizedString(@"Confirm", @"");
        NSString *strCancel = NSLocalizedString(@"Cancel", @"");
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:strConfirm style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self bookmarkConfigure:self.book ocrText:strOcr];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:strCancel style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissController:alert animated:YES];
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:confirmAction];
        [self presentController:alert animated:YES];
        
    } else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        //    [dic setObject:strQuote forKey:@"mQuote"];
        [dic setObject:image forKey:@"mImage"];
        
        [self createBookmark:self.book qDic:dic completed:^(BOOL isResult) {
            
        }];
    }
}

- (void)savePhoto:(UIImage *)image {
    PHAuthorizationStatus stauts = [PHPhotoLibrary authorizationStatus];
    
    if(stauts == PHAuthorizationStatusDenied) {
        return;
    }
    
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        PHAssetCollectionChangeRequest *collectionRequest = nil;;
        
        PHFetchResult * myFirstFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        
        PHAssetCollection *collection = nil;
        for(int i = 0 ; i < myFirstFetchResult.count ;i++ ){
            PHAssetCollection * assetCollection  =   [myFirstFetchResult objectAtIndex:i];
            
            NSString * albumName = assetCollection.localizedTitle;
            NSString * albumIdentifier = assetCollection.localIdentifier;
            if([albumName isEqualToString:@"whatIread"]){
                collection = assetCollection;
                break;
            }
            NSLog(@"%@",albumName);
            NSLog(@"%@",albumIdentifier);
            
        }
        
        if(collection){
            collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
        }else{
            collectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"whatIread"];
        }
        
        NSMutableArray *assets = [[NSMutableArray array]init];
        
        
        PHAssetChangeRequest *imageCreationRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        [assets addObject:imageCreationRequest.placeholderForCreatedAsset];
        
        
        [collectionRequest addAssets:assets];
        
    }completionHandler:^(BOOL success, NSError *error){
        
    }];
    //    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - G8Tesseract Delegate
- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
     NSLog(@"tesseract progress: %lu", (unsigned long)tesseract.progress);
    NSNumber *prog = [NSNumber numberWithUnsignedInteger:tesseract.progress];
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;
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
        NSString *strQuote = quote.data;
        UIImage *quoteImg = [UIImage imageWithData:quote.image];
        
        if (strQuote && strQuote.length > 0) {
            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
            paragraph.lineBreakMode = NSLineBreakByWordWrapping;
            CGFloat height = [strQuote boundingRectWithSize:CGSizeMake(cell.quoteLabel.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f], NSParagraphStyleAttributeName:paragraph} context:nil].size.height;
            
            [cell.quoteLabel setHidden:NO];
            [cell.quoteImgView setHidden:YES];
            [cell.quoteLabel setText:strQuote];
            cell.quoteLabelHeightConst.constant = height;
        }
        else if (quoteImg) {
            quoteImg = [self resizeImageWithWidth:quoteImg targetWidth:cell.quoteImgView.frame.size.width];
            [cell.quoteImgView setHidden:NO];
            [cell.quoteLabel setHidden:YES];
            [cell.quoteImgView setImage:quoteImg];
            cell.quoteImgViewHeightConst.constant = quoteImg.size.height;
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

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//{
//    NSLog(@"YJ << select collectionview cell");
//
////    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    //    [self bookConfigure:book indexPath:indexPath isModifyMode:YES];
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGSize cellSize = CGSizeMake(width, 50);
    
    if (quoteArr && quoteArr.count > 0) {
        
        Quote *quote = quoteArr[indexPath.item];
        NSString *strQuote = quote.data;
        UIImage *quoteImg = [UIImage imageWithData:quote.image];
        
        if (strQuote && strQuote.length > 0) {
            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
            paragraph.lineBreakMode = NSLineBreakByWordWrapping;
            CGFloat height = [strQuote boundingRectWithSize:CGSizeMake(width-30, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f], NSParagraphStyleAttributeName:paragraph} context:nil].size.height;
            cellSize = CGSizeMake(width, (30.f + 11.f + height));
        }
        else if (quoteImg) {
//            cellSize = CGSizeMake(width, 100);
            quoteImg = [self resizeImageWithWidth:quoteImg targetWidth:width-30];
            cellSize = CGSizeMake(width, (30.f + 11.f + quoteImg.size.height));
        }
    }
    return cellSize;
}

#pragma mark - BookShelfViewController Delegate
- (void)modifyBookCallback:(Book *)book
{
    if (book) {
        self.book = book;
        NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
        quoteArr = [self.book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];

        [self.bmCountLabel setText:[NSString stringWithFormat:@"%d", quoteArr.count]];
        [self.collectionView reloadData];
    }
}

#pragma mark - FetchedResultsController Delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
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
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
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
}

@end
