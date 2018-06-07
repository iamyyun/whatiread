//
//  BookmarkViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 6. 4..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "whatiread+CoreDataModel.h"
#import "CommonViewController.h"

@interface BookmarkViewController : CommonViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController <Book *> *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;

- (IBAction)addBtnAction:(id)sender;

@end
