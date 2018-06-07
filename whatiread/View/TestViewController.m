//
//  TestViewController.m
//  whatiread
//
//  Created by 양윤주 on 2018. 5. 30..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "TestViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Vision/Vision.h>

@interface TestViewController () <UIImagePickerControllerDelegate> {
    UIImage *pickImg;
    
    CIImage *imageToAnalyze;
    UIImage *originalImage;
}

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // AIzaSyC7xA1UVDcLsbV5rYc4h1duyL_UXkBf0u4
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pickBtnAction:(id)sender {
    UIImagePickerController *pickVC = [[UIImagePickerController alloc] init];
    pickVC.delegate = self;
    pickVC.allowsEditing = YES;
//    pickVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickVC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:pickVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    pickImg = chosenImage;
    [self.pickImageView setImage:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:pickImg.CGImage];
    
//    imageToAnalyze = chosenImage;
    originalImage = chosenImage;
    self.analyzeView.image = chosenImage;
    imageToAnalyze = [ciImage imageByApplyingOrientation:[pickImg imageOrientation]];
//    self.analyzeView.image = [ciImage imageByApplyingOrientation:[pickImg imageOrientation]];
    
    
    [self analyzeImage:ciImage];
}

- (void) analyzeImage:(CIImage *)image {
    
    NSDictionary *dic = [[NSDictionary alloc] init];
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCIImage:image orientation:(CGImagePropertyOrientation)[pickImg imageOrientation] options:dic];
    dispatch_async(dispatch_get_main_queue(), ^{
        VNDetectTextRectanglesRequest *request = [[VNDetectTextRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"%@", error);
            }
            else {
                for (VNTextObservation *box in request.results) {
                    NSArray *chars = box.characterBoxes;
                    if (chars.count != 0) {
                        NSLog(@"tiene boxes");
                    } else {
                        return;
                    }
//                    for (VNTextObservation *char1 in chars) {
                        UIView *viewSample = [self createBoxViewWithColor:[UIColor greenColor]];
//                        viewSample.frame = [self transformRect:char1.boundingBox to:self.analyzeView];
                    viewSample.frame = [self transformRect:box.boundingBox to:self.analyzeView];
                        self.analyzeView.image = originalImage;
                        [self.analyzeView addSubview:viewSample];
                    NSLog(@"YJ << text : %@", NSStringFromCGRect(viewSample.frame));
//                    }
                }
            }
        }];
        request.reportCharacterBoxes = TRUE;
        NSError *error;
        [handler performRequests:@[request] error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    });
}

-(UIView *) createBoxViewWithColor:(UIColor *)color {
    
    UIView *sampleView = [[UIView alloc] init];
    
    sampleView.layer.borderColor = color.CGColor;
    sampleView.layer.borderWidth = 2.0f;
    sampleView.backgroundColor = [UIColor clearColor];
    
    return sampleView;
}

-(CGRect)transformRect:(CGRect)FromRect to:(UIView *)viewRect {
    
    
//    CGRect toRect = (CGRect) {
//        toRect.size.width = FromRect.size.width * viewRect.frame.size.width,
//        toRect.size.height = FromRect.size.height * viewRect.frame.size.height,
//
//        toRect.origin.y = ((viewRect.frame.size.height) - (viewRect.frame.size.height * FromRect.origin.y))
//        // toRect.origin.y = toRect.origin.y - toRect.size.height, toRect.origin.x = FromRect.origin.x * viewRect.frame.size.width
//
//    };
    
    CGFloat maxX = 9999.0f;
    CGFloat minX = 0.0f;
    CGFloat maxY = 9999.0f;
    CGFloat minY = 0.0f;
    
    if (CGRectGetMaxX(FromRect) < maxX) {
        maxX = CGRectGetMaxX(FromRect);
    }
    if (CGRectGetMinX(FromRect) > minX) {
        minX = CGRectGetMinX(FromRect);
    }
    if (CGRectGetMaxY(FromRect) < maxY) {
        maxY = CGRectGetMaxY(FromRect);
    }
    if (CGRectGetMinY(FromRect) > minY) {
        minY = CGRectGetMinY(FromRect);
    }
    
    CGFloat xCord = maxX * viewRect.frame.size.width;
    CGFloat yCord = (1 - minY) * viewRect.frame.size.height;
    CGFloat width = (minX - maxX) * viewRect.frame.size.width;
    CGFloat height = (minY - maxY) * viewRect.frame.size.height;
    
    CGRect toRect = CGRectMake(xCord, yCord, width, height);
    return toRect;
}



@end
