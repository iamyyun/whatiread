//
//  AppDelegate.h
//  whatiread
//
//  Created by Yunju on 2018. 5. 30..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BookShelfViewController.h"
#import "IntroViewController.h"
#import "REFrostedViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, REFrostedViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property (strong, nonatomic) UIWindow *alertWindow;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) BookShelfViewController *rootViewController;
@property (strong, nonatomic) REFrostedViewController *frostedViewController;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@end

// Quote object에 type을 추가하여, 0:text, 1:image, 2:mixed로 구분하여 저장하고,
// cell에는 imageView와 TTTAttributedLabel로 text 출력
