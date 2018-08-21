//
//  BookmarkDetailViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 8. 4..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "whatiread+CoreDataModel.h"
#import "CoreDataAccess.h"

typedef void (^BookmarkDeleteCompleted)(NSIndexPath *indexPath);

@interface BookmarkDetailViewController : CommonViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController <Book *> *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController <Quote *> *quoteFetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, copy) BookmarkDeleteCompleted bookmarkDeleteCompleted;

@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

@property (nonatomic, strong) NSBlockOperation *updateBlock;

- (void)setBookmarkDetailCompositionHandler:(Book *)book bookmarkDeleteCompleted:(BookmarkDeleteCompleted)bookmarkDeleteCompleted;

@end
