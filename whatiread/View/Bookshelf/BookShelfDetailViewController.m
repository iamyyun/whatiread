//
//  BookShelfDetailViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 7. 5..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "BookShelfDetailViewController.h"
#import "BookShelfDetailCollectionViewCell.h"
#import "BookShelfViewController.h"

@interface BookShelfDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource, BookShelfViewControllerDelegate> {
    NSMutableArray *quoteArr;
}

@end

@implementation BookShelfDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:NO];
    [self setNaviBarType:BAR_EDIT title:nil image:nil];
    
    [self.bookShelfCollectionView setAllowsSelection:YES];
    [self.bookShelfCollectionView registerNib:[UINib nibWithNibName:@"BookShelfDetailCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"BookShelfDetailCollectionViewCell"];
    
    [self.rateView setStarFillColor:[UIColor colorWithHexString:@"F0C330"]];
    [self.rateView setStarNormalColor:[UIColor lightGrayColor]];
    [self.rateView setCanRate:NO];
    [self.rateView setStarSize:20.f];
    [self.rateView setStep:0.5f];
    
    if (self.book) {
        quoteArr = [NSMutableArray arrayWithArray:self.book.quotes];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yy.MM.dd"];
        NSString *strDate = [format stringFromDate:self.book.completeDate];
        
        [self.titleLabel setText:self.book.title];
        [self.authorLabel setText:self.book.author];
        [self.rateView setRating:self.book.rate];
        [self.bmCountLabel setText:[NSString stringWithFormat:@"%ld", quoteArr.count]];
        [self.completeDateLabel setText:strDate];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Set Block
- (void)setBookCompositionHandler:(Book *)book bookDeleteCompleted:(BookDeleteCompleted)bookDeleteCompleted bookmarkDeleteCompleted:(BookmarkDeleteCompleted)bookmarkDeleteCompleted
{
    self.book = book;
    self.bookDeleteCompleted = bookDeleteCompleted;
    self.bookmarkDeleteCompleted = bookmarkDeleteCompleted;
}

#pragma mark - Navigation Bar Actions
- (void)leftBarBtnClick:(id)sender
{
    [self popController:YES];
}

- (void)rightBarBtnClick:(id)sender
{
    NSInteger tag = [sender tag];
    // delete btn
    if (tag == BTN_TYPE_DELETE) {
        if (quoteArr && quoteArr.count > 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"해당 책 정보에 책갈피가 등록되어 있어 책 정보를 삭제 할 수 없습니다. 책갈피 삭제 후 삭제 해 주시기 바랍니다." message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [alert addAction:okAction];
            [self presentController:alert animated:YES];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete", @"") message:NSLocalizedString(@"Do you really want to delete?", @"") preferredStyle:UIAlertControllerStyleActionSheet];
            
            NSString *strFirst = NSLocalizedString(@"Deleting", @"");
            NSString *strSecond = NSLocalizedString(@"Cancel", @"");
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                if (self.bookDeleteCompleted) {
                    self.bookDeleteCompleted(self.indexPath);
                    [self popController:YES];
                }
            }];
            UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alert addAction:firstAction];
            [alert addAction:secondAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    // edit btn
    else if (tag == BTN_TYPE_EDIT) {
        
    }
}

#pragma mark - Actions
- (void)bookmarkCellDelBtnAction:(id)sender
{
    NSLog(@"YJ << bookmark cell delete : %ld", [sender tag]);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete", @"") message:NSLocalizedString(@"Do you really want to delete?", @"") preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *strFirst = NSLocalizedString(@"Deleting", @"");
    NSString *strSecond = NSLocalizedString(@"Cancel", @"");
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if (self.bookmarkDeleteCompleted) {
            self.bookmarkDeleteCompleted(self.indexPath, [sender tag], (id<BookShelfViewControllerDelegate>)self);
        }
    }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)bookmarkCellEditBtnAction:(id)sender
{
    NSLog(@"YJ << bookmark cell edit : %ld", [sender tag]);
}

#pragma mark - UICollectionViewDataSource
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"BookShelfDetailCollectionViewCell";
    BookShelfDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
    }
    
    if(quoteArr && quoteArr.count > 0) {
        NSString *strQuote = quoteArr[indexPath.item];
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        CGFloat height = [strQuote boundingRectWithSize:CGSizeMake(cell.quoteLabel.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f], NSParagraphStyleAttributeName:paragraph} context:nil].size.height;
        
        [cell.bMarkCountLabel setText:[NSString stringWithFormat:@"%ld", indexPath.item+1]];
        [cell.quoteLabel setText:strQuote];
        cell.quoteLabelHeightConst.constant = height;
        
        [cell.delBtn addTarget:self action:@selector(bookmarkCellDelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.delBtn setTag:indexPath.item];
        [cell.editBtn addTarget:self action:@selector(bookmarkCellEditBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.editBtn setTag:indexPath.item];
    }
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    int bmCount = 0;
    if (quoteArr && quoteArr.count > 0) {
        bmCount = quoteArr.count;
    }
    
    return bmCount;
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//{
//    NSLog(@"YJ << select collectionview cell");
//
////    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    //    [self bookConfigure:book indexPath:indexPath isModifyMode:YES];
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize;
    if (quoteArr && quoteArr.count > 0) {
        CGFloat width = [[UIScreen mainScreen] bounds].size.width;
        
        NSString *strQuote = quoteArr[indexPath.item];
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        CGFloat height = [strQuote boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f], NSParagraphStyleAttributeName:paragraph} context:nil].size.height;
        cellSize = CGSizeMake(width, (30.f + 11.f + height));
    }
    return cellSize;
}

#pragma mark - BookShelfViewController Delegate
- (void)modifyBookCallback:(Book *)book
{
    if (book) {
        self.book = book;
        quoteArr = [NSMutableArray arrayWithArray:self.book.quotes];
        
        [self.bmCountLabel setText:[NSString stringWithFormat:@"ld", quoteArr.count]];
        [self.bookShelfCollectionView reloadData];
    }
}

@end
