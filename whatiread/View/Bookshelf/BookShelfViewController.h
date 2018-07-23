//
//  BookShelfViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 7. 13..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "whatiread+CoreDataModel.h"
#import "CoreDataAccess.h"
#import "CommonViewController.h"

@protocol BookShelfViewControllerDelegate

//- (void)modifyBookmarkCallback:(Book *)book;
//- (void)deleteBookmarkCallback:(Book *)book;
- (void)modifyBookCallback:(Book *)book;

@end

@interface BookShelfViewController : CommonViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController <Book *> *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *sortBtn;
@property (weak, nonatomic) IBOutlet UILabel *sortLabel;
@property (weak, nonatomic) IBOutlet UILabel *bmCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *bCountLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;

- (IBAction)addBtnAction:(id)sender;
- (IBAction)sortBtnAction:(id)sender;

@property (weak) id<BookShelfViewControllerDelegate> bookshelfDelegate;

@end
