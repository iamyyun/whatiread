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
#import "TestViewController.h"
#import "REFrostedViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, REFrostedViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
//@property (strong, nonatomic) TestViewController *rootViewController;
@property (strong, nonatomic) BookShelfViewController *rootViewController;
@property (strong, nonatomic) REFrostedViewController *frostedViewController;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

