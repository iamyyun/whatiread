//
//  IndicatorUtil.m
//  PicasoBank
//
//  Created by Choi Wonsik on 2015. 9.
//  Copyright (c) 2014년 ATsolution. All rights reserved.
//

#import "IndicatorUtil.h"
#import "AppDelegate.h"
//#import "SplashViewController.h"

@interface IndicatorUtil()

@property (nonatomic, strong) NSMutableArray *arrImage;
@property (nonatomic, strong) UIImage *coImage;
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, strong) UIImageView *coImageView;

@property (nonatomic, strong) UILabel *descLabel;

@end



@implementation IndicatorUtil


#pragma mark - 싱글톤 객체 생성
+ (IndicatorUtil *)sharedIndicator
{
    static IndicatorUtil *_sharedIndicator;
	if(!_sharedIndicator) {
		static dispatch_once_t oncePredicate;
        
		dispatch_once(&oncePredicate, ^{
			_sharedIndicator = [[super allocWithZone:nil] init];
        });
    }
    
    return _sharedIndicator;
}

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        //로딩 이미지 설정
        self.arrImage = [[NSMutableArray alloc] init];
        for( int i = 1 ; i <= 8 ; i++ )
        {
            NSString * imageName = [NSString stringWithFormat:@"icon_progress_%02d", i];
            
            UIImage *dImg = [UIImage imageNamed:imageName];
            [self.arrImage addObject:dImg];
        }
    }
    
	return self;
}

#pragma mark - 프로그레스 시작 클래스 함수
+ (void)startProcessIndicator
{
    NSLog(@"startProcessIndicator");
    
    [[IndicatorUtil sharedIndicator] startAlertIndicator:nil];
}

+ (void)startProcessIndicator:(NSString *)title
{
    NSLog(@"startProcessIndicator with title");
    
    [[IndicatorUtil sharedIndicator] startAlertIndicator:title];
}

#pragma mark - 프로그레스 시작 인스턴스 함수
//- (void)startAlertIndicator
//{
//    [self performSelectorOnMainThread:@selector(loadIndicator) withObject:nil waitUntilDone:NO];
//}

- (void)startAlertIndicator:(NSString *)title
{
    [self performSelectorOnMainThread:@selector(loadIndicator:) withObject:title waitUntilDone:NO];
}


- (void)loadIndicator:(NSString *)title
{
    //기기 상태바 스피너 활성화
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self stopAlertIndicator];
    
    if (title) {
        [self startAlertIndicator:title isShow:YES];
    } else {
        [self startAlertIndicator:NSLocalizedString(@"Processing.", @"") isShow:NO];
    }
    
    [IndicatorUtil sharedIndicator].bProcessIndicator = YES;
}

#pragma mark - 프로그레스 중지 클래스 함수
+ (void)stopProcessIndicator
{
    if( [IndicatorUtil sharedIndicator].ignoreIndicator )
    {
        return;
    }
    NSLog(@"stopProcessIndicator");
	[[IndicatorUtil sharedIndicator] hideIndicator];
}

#pragma mark - 프로그레스 중지 인스턴스 함수
- (void)hideIndicator
{
    [self performSelectorOnMainThread:@selector(stopAlertIndicator) withObject:nil waitUntilDone:NO];
}

#pragma mark - 프로그레스 중지 구현체
- (void)stopAlertIndicator
{
    //기기 상태바 스피너 비활성화
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    
	if(self.uvWaitView != nil)
	{
        if (_loadingImageView)
        {
            if ([_loadingImageView isAnimating])
            {
                [_loadingImageView stopAnimating];
            }
            [self.loadingImageView removeFromSuperview];
            self.loadingImageView = nil;
        }

        if (self.coImageView != nil)
        {
            [self.coImageView removeFromSuperview];
            self.coImageView = nil;
        }

        if (self.uvWaitView)
        {
            [self.uvWaitView removeFromSuperview];
            self.uvWaitView = nil;
        }
	}
    
    [IndicatorUtil sharedIndicator].bProcessIndicator = NO;
}

#pragma mark - 프로그레스 시작 구현체
- (void)startAlertIndicator:(NSString*)title isShow:(BOOL)isShow
{
    self.uvWaitView = [[UIView alloc] init];
    self.uvWaitView.isAccessibilityElement = YES;
    self.uvWaitView.accessibilityLabel = title;
    
    CGSize deviceSize = [[UIScreen mainScreen] bounds].size;
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        if( deviceSize.width < deviceSize.height )
        {
            [self.uvWaitView setFrame:CGRectMake(0, 0, deviceSize.width, deviceSize.height)];
//            [self.uvWaitView setFrame:CGRectMake(0, 0, deviceSize.height, deviceSize.width)];
        }
        else
        {
            [self.uvWaitView setFrame:CGRectMake(0, 0, deviceSize.width, deviceSize.height)];
        }
        
        self.uvWaitView.center = SHAREDAPPDELEGATE.window.center;
    }
    else
    {
        [self.uvWaitView setFrame:CGRectMake(0, 0, deviceSize.width, deviceSize.height)];
    }
    
    [self.uvWaitView setBackgroundColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.8]];
    
    int iWidth = 80.f;
    int iHeight = 80.f;
    //뱅글뱅글 이미지 사이즈 반값
    int iImageGap = (int)(iWidth/2);
    CGPoint centerRect = CGPointMake(self.uvWaitView.bounds.size.width/2, self.uvWaitView.bounds.size.height/2);
    int iPosX = (centerRect.x - iImageGap);
    int iPosY = centerRect.y - iImageGap + 20.f;
    
    self.loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(iPosX, iPosY, iWidth, iHeight)];
    [self.loadingImageView setBackgroundColor:[UIColor clearColor]];
    [self.loadingImageView setAnimationImages:_arrImage];
    [self.loadingImageView setAnimationDuration:1];

    
    [self.uvWaitView addSubview:self.loadingImageView];

    [self.loadingImageView startAnimating];
    
    // label
    if (isShow) {
        CGFloat width = [title boundingRectWithSize:CGSizeMake(1000, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.f]} context:nil].size.width;
        self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake((deviceSize.width-width)/2, iPosY+iHeight+5, width, 15.f)];
        [self.descLabel setText:title];
        [self.descLabel setFont:[UIFont systemFontOfSize:14.f]];
        [self.descLabel setTextColor:[UIColor colorWithHexString:@"1abc9c"]];
        
        [self.uvWaitView addSubview:self.descLabel];
    }
    
    
    iWidth = 80;
    iHeight = 80;
    iImageGap = (int)(iWidth/2);
    iPosX = (centerRect.x - iImageGap);
    
    self.coImageView = [[UIImageView alloc] initWithFrame:CGRectMake(iPosX, iPosY, iWidth, iHeight)];
    [self.coImageView setBackgroundColor:[UIColor clearColor]];
	
	// 한/영 모드에 따라 이미지 교체
    UIImage* img = self.coImage;
	[self.coImageView setImage: img];
    
	[self.uvWaitView addSubview:self.coImageView];
    
    [SHAREDAPPDELEGATE.window addSubview:self.uvWaitView];
}

#pragma mark - 프로그레스 진행 중인지 확인
- (BOOL)isAnimating
{
	if(self.uvWaitView != nil)
	{
        return [_loadingImageView isAnimating];
    }
    else
    {
        return NO;
    }
}


/**
   iOS6.0 버전 이하에서 iPad의 가로 회전이 안되는 현상을 수정
*/
- (void) setTransformForCurrentOrientation: (UIView*)aView {

	if ([[[UIDevice currentDevice] systemVersion] compare: @"7.0"] == NSOrderedAscending) {

		UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
		CGFloat radians                    = 0;

		if (UIInterfaceOrientationIsLandscape(orientation)) {
			if (orientation == UIInterfaceOrientationLandscapeLeft) {
				radians = -(CGFloat)M_PI_2;
			}
			else {
				radians = (CGFloat)M_PI_2;
			}
		}
		else {
			if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
				radians = (CGFloat)M_PI;
			}
			else {
				radians = 0;
			}
		}

		CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(radians);
		[aView setTransform: rotationTransform];
	}
}

@end
