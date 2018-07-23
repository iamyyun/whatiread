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

- (IBAction)closeBtnAction:(id)sender;

- (void)setBookSearchHandler:(BookSelectCompleted)bookSelectCompleted;

@end
