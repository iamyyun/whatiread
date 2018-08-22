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

@property (weak, nonatomic) NSFetchedResultsController <Book *> *fetchedResultsController;
@property (weak, nonatomic) NSFetchedResultsController <Quote *> *quoteFetchedResultsController;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) NSManagedObjectContext *quoteManagedObjectContext;

@property (nonatomic, copy) BookmarkDeleteCompleted bookmarkDeleteCompleted;

@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

- (void)setBookmarkDetailCompositionHandler:(Book *)book bookmarkDeleteCompleted:(BookmarkDeleteCompleted)bookmarkDeleteCompleted;

@end
