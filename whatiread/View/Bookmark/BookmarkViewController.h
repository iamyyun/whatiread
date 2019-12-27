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
#import "CoreDataAccess.h"

@interface BookmarkViewController : CommonViewController <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) NSFetchedResultsController <Book *> *fetchedResultsController;
@property (weak, nonatomic) NSFetchedResultsController <Quote *> *quoteFetchedResultsController;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) NSManagedObjectContext *quoteManagedObjectContext;

// localize language
@property (weak, nonatomic) IBOutlet UILabel *noBookLangLabel;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *sortBtn;
@property (weak, nonatomic) IBOutlet UILabel *sortLabel;
@property (weak, nonatomic) IBOutlet UILabel *bmCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *bCountLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIView *dimBgView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSearchConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property (nonatomic, strong) NSBlockOperation *updateBlock;

- (IBAction)sortBtnAction:(id)sender;

@end
