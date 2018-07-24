//
//  IndicatorUtil.h
//  PicasoBank
//
//  Created by Choi Wonsik on 2015. 9.
//  Copyright (c) 2014년 ATsolution. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IndicatorUtil : NSObject

@property (nonatomic, assign) BOOL	bProcessIndicator;	//indicator 진행중 여부
//@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIView *uvWaitView;
//@property (nonatomic, strong) UILabel *lbTitle;
@property (nonatomic, strong) UIView *viewContainer;

@property (nonatomic, assign) BOOL ignoreIndicator;

+ (IndicatorUtil *)sharedIndicator;
+ (void)startProcessIndicator;
+ (void)stopProcessIndicator;

- (void)startAlertIndicator;
- (void)startAlertIndicator:(NSString*)title;
- (void)stopAlertIndicator;
- (BOOL)isAnimating;

- (void)loadIndicator;


@end
