//
//  AddBookmarkViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 7. 25..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "AddBookmarkViewController.h"
#import "TOCropViewController.h"
#import <Photos/Photos.h>
#import <TesseractOCR/TesseractOCR.h>

@interface AddBookmarkViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate, G8TesseractDelegate> {
    
    BOOL isOcrActive; // is TextOCR active
    BOOL isEdited;
    
    UITapGestureRecognizer *bgTap;
}

@end

@implementation AddBookmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNaviBarType:BAR_ADD title:@"책갈피 등록" image:nil];
    
    isEdited = NO;
    
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(writeFinished)];
    keyboardToolbar.items = @[flexBarButton, doneBarBtn];
    self.textView.inputAccessoryView = keyboardToolbar;
    [self.textView setShowsHorizontalScrollIndicator:NO];
    [self.textView setAlwaysBounceHorizontal:NO];
    [self.textView setContentInset:UIEdgeInsetsZero];
    self.textView.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5);
    self.textView.textContainer.lineFragmentPadding = 0;
    
//    [self.textView becomeFirstResponder];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.book) {
        if (self.isModifyMode) {
            if (self.book.quotes.count > 0) {
                NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
                NSArray *quoteArr = [self.book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
                Quote *quote = quoteArr[self.indexPath.item];
                [self.textView setAttributedText:quote.data];
            }
        }
    }
    
    if (self.strOcrText && self.strOcrText.length > 0) {
        [self.textView setText:self.strOcrText];
    }
    
    // Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShowNote:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHideNote:) name:UIKeyboardWillHideNotification object:self.view.window];
    bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(writeFinished)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) writeFinished {
    [self.view endEditing:YES];
}

// set blocks
- (void)setBookmarkCompositionHandler:(Book *)book bookmarkCreateCompleted:(BookmarkCreateCompleted)bookmarkCreateCompleted bookmarkModifyCompleted:(BookmarkModifyCompleted)bookmarkModifyCompleted
{
    self.book = book;
    self.bookmarkCreateCompleted = bookmarkCreateCompleted;
    self.bookmarkModifyCompleted = bookmarkModifyCompleted;
}

#pragma mark - Actions
// textInput Button Action
- (IBAction)textInputBtnAction:(id)sender {
    isOcrActive = YES;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *strCamera = @"사진 찍기";
    NSString *strAlbum = @"사진 보관함에서 추가";
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
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [alert addAction:cameraAction];
    [alert addAction:albumAction];
    [alert addAction:cancelAction];
    [self presentController:alert animated:YES];
}

- (IBAction)photoInputBtnAction:(id)sender {
    isOcrActive = NO;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *strCamera = @"사진 찍기";
    NSString *strAlbum = @"사진 보관함에서 추가";
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
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [alert addAction:cameraAction];
    [alert addAction:albumAction];
    [alert addAction:cancelAction];
    [self presentController:alert animated:YES];
}

#pragma mark - Navigation Action
- (void)leftBarBtnClick:(id)sender {
    if (isEdited) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Close", @"") message:@"작성중인 글이 있습니다." preferredStyle:UIAlertControllerStyleActionSheet];
        
        NSString *strFirst = @"계속 쓰기";
        NSString *strSecond = @"삭제하고 나가기";
        NSString *strThird = @"저장하고 나가기";
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
        }];
        UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self popController:YES];
        }];
        UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:strThird style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self rightBarBtnClick:nil];
        }];
        
        [alert addAction:firstAction];
        [alert addAction:secondAction];
        [alert addAction:thirdAction];
        [self presentController:alert animated:YES];
    }
    else {
        [self popController:YES];
    }
}

- (void)rightBarBtnClick:(id)sender {
    if (self.textView.attributedText.length <= 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"책갈피를 입력해주세요." message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [alert addAction:okAction];
        [self presentController:alert animated:YES];
    }
    if (self.isModifyMode) {
        if (self.bookmarkModifyCompleted) {
            self.bookmarkModifyCompleted(self.textView.attributedText, self.indexPath);
            [self popController:YES];
        }
    }
    else {
        if (self.bookmarkCreateCompleted) {
            self.bookmarkCreateCompleted(self.textView.attributedText);
            [self popController:YES];
        }
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"YJ << textview attributed text : %@", textView.attributedText);
    NSLog(@"YJ << textview storageText : %@", textView.textStorage);
}

- (void)textViewDidChange:(UITextView *)textView {
    isEdited = YES;
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
        
        __block NSString *strOcr = @"";
        
        [IndicatorUtil startProcessIndicator];
        G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"kor+eng"];
        operation.tesseract.image = [image g8_blackAndWhite];
        operation.recognitionCompleteBlock = ^(G8Tesseract *recognizedTesseract) {
            // Retrieve the recognized text upon completion
            
            strOcr = [recognizedTesseract recognizedText];
            [IndicatorUtil stopProcessIndicator];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"텍스트 추출" message:strOcr preferredStyle:UIAlertControllerStyleAlert];
            
            NSString *strConfirm = NSLocalizedString(@"Confirm", @"");
            NSString *strCancel = NSLocalizedString(@"Cancel", @"");
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:strConfirm style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:strOcr];
                [self.textView.textStorage insertAttributedString:attrStr atIndex:self.textView.selectedRange.location];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:strCancel style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self dismissController:alert animated:YES];
            }];
            
            [alert addAction:cancelAction];
            [alert addAction:confirmAction];
            [self presentController:alert animated:YES];
        };
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue addOperation:operation];
        
    } else {
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = image;
        
        CGFloat oldWidth = textAttachment.image.size.width;
        
        //I'm subtracting 10px to make the image display nicely, accounting
        //for the padding inside the textView
        CGFloat scaleFactor = oldWidth / (self.textView.frame.size.width - 10);
        textAttachment.image = [UIImage imageWithCGImage:textAttachment.image.CGImage scale:scaleFactor orientation:UIImageOrientationUp];
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [self.textView.textStorage insertAttributedString:attrStringWithImage atIndex:self.textView.selectedRange.location];
        
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        //    [dic setObject:strQuote forKey:@"mQuote"];
//        [dic setObject:image forKey:@"mImage"];
        
//        [self createBookmark:self.book qDic:dic completed:^(BOOL isResult) {
        
//        }];
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

#pragma mark - keyboard actions
- (void)handleKeyboardWillShowNote:(NSNotification *)notification
{
    [self.view addGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    self.textViewBottomMarginConst.constant = keyboardSize.height;
    [self.view updateConstraints];
}

- (void)handleKeyboardWillHideNote:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.textViewBottomMarginConst.constant = 60.f;
    [self.view updateConstraints];
}

@end
