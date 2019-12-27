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
+ (void)startProcessIndicator:(NSString *)title;
+ (void)stopProcessIndicator;

- (void)startAlertIndicator:(NSString *)title;
- (void)startAlertIndicator:(NSString*)title isShow:(BOOL)isShow;
- (void)stopAlertIndicator;
- (BOOL)isAnimating;

- (void)loadIndicator:(NSString *)title;


@end
