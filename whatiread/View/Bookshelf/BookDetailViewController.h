//
//  BookDetailViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 7. 5..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "whatiread+CoreDataModel.h"
#import "CoreDataAccess.h"
#import "RateView.h"
#import "BookShelfViewController.h"

@interface BookDetailViewController : CommonViewController <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) NSFetchedResultsController <Book *> *fetchedResultsController;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) Book *book;

// localize language
@property (weak, nonatomic) IBOutlet UILabel *authorLangLabel;
@property (weak, nonatomic) IBOutlet UILabel *publisherLangLabel;
@property (weak, nonatomic) IBOutlet UILabel *pubDateLangLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLangLabel;
@property (weak, nonatomic) IBOutlet UILabel *compDateLangLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLangLabel;
@property (weak, nonatomic) IBOutlet UILabel *bmLangLabel;
@property (weak, nonatomic) IBOutlet UILabel *noBmLangLabel;
//

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *publisherLabel;
@property (weak, nonatomic) IBOutlet UILabel *pubDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *compDateLabel;
@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImgView;
@property (weak, nonatomic) IBOutlet UILabel *bmCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *addBmBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBsBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBsBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoViewHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverImgWidthConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverImgLeadingConst;

@property (nonatomic, strong) NSBlockOperation *updateBlock;

- (IBAction)addBookmarkBtnAction:(id)sender;
- (IBAction)EditBookShelfBtnAction:(id)sender;
- (IBAction)deleteBookShelfBtnAction:(id)sender;

@end
