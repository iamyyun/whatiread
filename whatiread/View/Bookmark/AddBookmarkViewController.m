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
    BOOL isPictureExist;
    
    UITapGestureRecognizer *bgTap;
}

@end

@implementation AddBookmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNaviBarType:BAR_ADD title:NSLocalizedString(@"Add Bookmark", @"") image:nil];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithHexString:@"1abc9c"]];
    
    // localize language
    [self.textInputLangLabel setText:NSLocalizedString(@"Text Recognition", @"")];
    [self.photoInputLangLabel setText:NSLocalizedString(@"Add Photo", @"")];
    
    isEdited = NO;
    isPictureExist = NO;
    
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
    [self.textView setFont:[UIFont systemFontOfSize:14.f]];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.book) {
        if (self.isModifyMode) {
            if (self.book.quotes.count > 0) {
                NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
                NSArray *quoteArr = [self.book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
                Quote *quote = quoteArr[self.indexPath.item];
                NSAttributedString *attrQuote = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)quote.data]; // nsdate -> nsattributedstring
                [self.textView setAttributedText:attrQuote];
                
                [attrQuote enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attrQuote.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
                    if (![value isKindOfClass:[NSTextAttachment class]]) {
                        return;
                    } else {
                        [self.photoInputView setBackgroundColor:[UIColor lightGrayColor]];
                        isPictureExist = YES;
                    }
                }];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textView setFont:[UIFont systemFontOfSize:14.f]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [IndicatorUtil stopProcessIndicator];
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
    
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate.alertWindow makeKeyAndVisible];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *strCamera = NSLocalizedString(@"Take Photo", @"");
    NSString *strAlbum = NSLocalizedString(@"Add from Library", @"");
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:strCamera style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//        [appDelegate.alertWindow setHidden:YES];
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentController:picker animated:YES];
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:strAlbum style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [appDelegate.alertWindow setHidden:YES];
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentController:picker animated:YES];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
//        [appDelegate.alertWindow setHidden:YES];
    }];
    
    [alert addAction:cameraAction];
    [alert addAction:albumAction];
    [alert addAction:cancelAction];
    [self presentController:alert animated:YES];
//    [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (IBAction)photoInputBtnAction:(id)sender {
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate.alertWindow makeKeyAndVisible];
    
    if (isPictureExist) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Only 1 picture can added.", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [appDelegate.alertWindow setHidden:YES];
        }];
        [alert addAction:okAction];
        [self presentController:alert animated:YES];
//        [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    } else {
        isOcrActive = NO;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        NSString *strCamera = NSLocalizedString(@"Take Photo", @"");
        NSString *strAlbum = NSLocalizedString(@"Add from Library", @"");
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:strCamera style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//            [appDelegate.alertWindow setHidden:YES];
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentController:picker animated:YES];
        }];
        UIAlertAction *albumAction = [UIAlertAction actionWithTitle:strAlbum style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [appDelegate.alertWindow setHidden:YES];
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentController:picker animated:YES];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
//            [appDelegate.alertWindow setHidden:YES];
        }];
        
        [alert addAction:cameraAction];
        [alert addAction:albumAction];
        [alert addAction:cancelAction];
        [self presentController:alert animated:YES];
//        [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Navigation Action
- (void)leftBarBtnClick:(id)sender {
    if (isEdited) {
//        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        [appDelegate.alertWindow makeKeyAndVisible];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Close", @"") message:NSLocalizedString(@"Finish writing the bookmark.", @"") preferredStyle:UIAlertControllerStyleActionSheet];
        
        NSString *strFirst = NSLocalizedString(@"Keep writing", @"");
        NSString *strSecond = NSLocalizedString(@"Delete & Leave", @"");
        NSString *strThird = NSLocalizedString(@"Save & Leave", @"");
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//            [appDelegate.alertWindow setHidden:YES];
        }];
        UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [appDelegate.alertWindow setHidden:YES];
            
            [self popController:YES];
        }];
        UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:strThird style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [appDelegate.alertWindow setHidden:YES];
            
            [self rightBarBtnClick:nil];
        }];
        
        [alert addAction:firstAction];
        [alert addAction:secondAction];
        [alert addAction:thirdAction];
        [self presentController:alert animated:YES];
//        [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    else {
        [self popController:YES];
    }
}

- (void)rightBarBtnClick:(id)sender {
    if (self.textView.attributedText.length <= 0) {
//        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        [appDelegate.alertWindow makeKeyAndVisible];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please write quotes.", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [appDelegate.alertWindow setHidden:YES];
        }];
        [alert addAction:okAction];
        [self presentController:alert animated:YES];
//        [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    } else {
        NSAttributedString *attrStr = self.textView.attributedText;
        NSData *attrData = [NSKeyedArchiver archivedDataWithRootObject:attrStr];

        // cant (1048183 ~ up)
        // can (1047055 ~ down)
        if (attrData.length > 1047000) {
            [attrStr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attrStr.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
                if (![value isKindOfClass:[NSTextAttachment class]]) {
                    return;
                }
                
                for (int i = 1; i < 30; i++) {
                    
                    NSTextAttachment *attachment = (NSTextAttachment *)value;
                    UIImage *oldImg = attachment.image;
                    NSData *imgData = UIImageJPEGRepresentation(oldImg, 1.0f);
                    
                    CGFloat oldWidth = oldImg.size.width;
                    CGFloat oldHeight = oldImg.size.height;
                    CGFloat newWidth = oldWidth/i;
                    CGFloat newHeight = oldHeight/i;
                    
                    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
                    [oldImg drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
                    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    attachment.image = newImg;
                    
                    NSAttributedString *attrImg = [NSAttributedString attributedStringWithAttachment:attachment];
                    
                    [self.textView.textStorage replaceCharactersInRange:range withAttributedString:attrImg];
                    
                    NSAttributedString *afterAttr = self.textView.attributedText;
                    NSData *afterData = [NSKeyedArchiver archivedDataWithRootObject:afterAttr];
                    
                    if (afterData.length <= 2000000) {
                        break;
                    }
                }
            }];
        }
        
        if (self.isModifyMode) {
            if (self.bookmarkModifyCompleted) {
                [IndicatorUtil startProcessIndicator];
                self.bookmarkModifyCompleted(self.textView.attributedText, self.indexPath);
                [self popController:YES];
            }
        }
        else {
            if (self.bookmarkCreateCompleted) {
                [IndicatorUtil startProcessIndicator];
                self.bookmarkCreateCompleted(self.textView.attributedText);
                [self popController:YES];
            }
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
    
    NSAttributedString *attrQuote = textView.attributedText;
    [self.photoInputView setBackgroundColor:[UIColor whiteColor]];
    isPictureExist = NO;
    
    [attrQuote enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attrQuote.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (![value isKindOfClass:[NSTextAttachment class]]) {
            return;
        } else {
            
            NSTextAttachment *attachment = (NSTextAttachment *)value;
            if (attachment.image) {
            [self.photoInputView setBackgroundColor:[UIColor lightGrayColor]];
               isPictureExist = YES;
            }
        }
    }];
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
    
    NSString *strStat = [[NSUserDefaults standardUserDefaults] objectForKey:SWITCH_SAVEPIC_STATUS];
    if (!strStat || strStat.length <= 0) {
        strStat = SWITCH_SAVEPIC_ON;
        [[NSUserDefaults standardUserDefaults] setObject:SWITCH_SAVEPIC_ON forKey:SWITCH_SAVEPIC_STATUS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if ([strStat isEqualToString:SWITCH_SAVEPIC_ON]) {
        [self savePhoto:resultImage];
    }
    
    if (isOcrActive) {
        [IndicatorUtil startProcessIndicator];
        [self performSelector:@selector(recognizeText:) withObject:resultImage afterDelay:0.2];
        
    } else {
        [IndicatorUtil startProcessIndicator:NSLocalizedString(@"Compressing Image", @"")];
        [self performSelector:@selector(compressImage:) withObject:resultImage afterDelay:0.2];
    }
}

- (void)recognizeText:(UIImage *)resultImage {
    __block NSString *strOcr = @"";
           
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"kor+eng" configDictionary:nil configFileNames:nil absoluteDataPath:[NSBundle mainBundle].bundlePath engineMode:G8OCREngineModeTesseractOnly];
   
    operation.tesseract.image = [resultImage g8_blackAndWhite];
    operation.recognitionCompleteBlock = ^(G8Tesseract *recognizedTesseract) {
       
        strOcr = [recognizedTesseract recognizedText];
        [IndicatorUtil stopProcessIndicator];
       
//        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        [appDelegate.alertWindow makeKeyAndVisible];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Text Recognition", @"") message:strOcr preferredStyle:UIAlertControllerStyleAlert];
       
        NSString *strConfirm = NSLocalizedString(@"Confirm", @"");
        NSString *strCancel = NSLocalizedString(@"Cancel", @"");
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:strConfirm style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//            [appDelegate.alertWindow setHidden:YES];
            
           NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:strOcr];
           [self.textView.textStorage insertAttributedString:attrStr atIndex:self.textView.selectedRange.location];
           [self.textView setFont:[UIFont systemFontOfSize:14.f]];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:strCancel style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [appDelegate.alertWindow setHidden:YES];
            
            [self dismissController:alert animated:YES];
        }];
       
        [alert addAction:cancelAction];
        [alert addAction:confirmAction];
        [self presentController:alert animated:YES];
//        [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        
        [IndicatorUtil stopProcessIndicator];
   };
   
   NSOperationQueue *queue = [[NSOperationQueue alloc] init];
   [queue addOperation:operation];
}

- (void)compressImage:(UIImage *)resultImage {
    
    NSAttributedString *attrStringWithImage;
    
    for (int i = 1; i < 50; i++) {
        // calculate original image size
        NSTextAttachment *origTextAttach = [[NSTextAttachment alloc] init];
        origTextAttach.image = resultImage;
        
        attrStringWithImage = [NSAttributedString attributedStringWithAttachment:origTextAttach];
        NSData *origData = [NSKeyedArchiver archivedDataWithRootObject:attrStringWithImage];
        NSUInteger origLength = origData.length;
        
        CGFloat oldWidth = origTextAttach.image.size.width;
        CGFloat oldHeight = origTextAttach.image.size.height;
        CGFloat newWidth = oldWidth/i;
        CGFloat newHeight = oldHeight/i;
       
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        [resultImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
        UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGFloat scaleFactor = newWidth / (self.textView.frame.size.width - 10);
        origTextAttach.image = [UIImage imageWithCGImage:newImg.CGImage scale:scaleFactor orientation:newImg.imageOrientation];
        
        attrStringWithImage = [NSAttributedString attributedStringWithAttachment:origTextAttach];
        origData = [NSKeyedArchiver archivedDataWithRootObject:attrStringWithImage];
        origLength = origData.length;
        
        // cant (1048183 ~ up)
        // can (1047055 ~ down)
        if (origLength <= 1047000) {
            break;
        }
    }
    
    [self.textView.textStorage insertAttributedString:attrStringWithImage atIndex:self.textView.selectedRange.location];
    [self.textView setFont:[UIFont systemFontOfSize:14.f]];
    
    [self.photoInputView setBackgroundColor:[UIColor lightGrayColor]];
    isPictureExist = YES;
    
    [IndicatorUtil stopProcessIndicator];
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
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.textViewBottomMarginConst.constant = keyboardSize.height;
    [self.view updateConstraints];
}

- (void)handleKeyboardWillHideNote:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.textViewBottomMarginConst.constant = 60.f;
    [self.view updateConstraints];
}

@end
