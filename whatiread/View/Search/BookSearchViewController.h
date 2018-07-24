//
//  BookSearchViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 7. 23..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "CommonViewController.h"

typedef void (^BookSelectCompleted)(NSDictionary *bookDic);

@interface BookSearchViewController : CommonViewController

@property (nonatomic, copy) BookSelectCompleted bookSelectCompleted;

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIView *scanView;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *scanCloseBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
@property (weak, nonatomic) IBOutlet UIButton *flashBtn;

- (IBAction)closeBtnAction:(id)sender;

- (IBAction)scanCloseBtnAction:(id)sender;
- (IBAction)swtichBtnAction:(id)sender;
- (IBAction)flashBtnAction:(id)sender;

- (void)setBookSearchHandler:(BookSelectCompleted)bookSelectCompleted;

@end
