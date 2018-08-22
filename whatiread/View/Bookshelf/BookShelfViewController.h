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

@interface BookShelfViewController : CommonViewController <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) NSFetchedResultsController <Book *> *fetchedResultsController;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *sortBtn;
@property (weak, nonatomic) IBOutlet UILabel *sortLabel;
@property (weak, nonatomic) IBOutlet UILabel *bmCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *bCountLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIView *dimBgView;

@property (nonatomic, strong) NSBlockOperation *updateBlock;

- (IBAction)addBtnAction:(id)sender;
- (IBAction)sortBtnAction:(id)sender;

@end
