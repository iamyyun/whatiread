//
//  BookSearchViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 7. 23..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "BookSearchViewController.h"
#import "BookSearchCollectionViewCell.h"
#import "AddBookShelfViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define SEARCH_COUNT_ONCE  20

@interface BookSearchViewController () <UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate> {
    NSMutableArray *searchArr;
    
    NSInteger searchIndex;
    NSInteger totalCount;
}

@end

@implementation BookSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    searchArr = [NSMutableArray array];
    
    [self.collectionView setAllowsSelection:YES];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BookSearchCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"BookSearchCollectionViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBookSearchHandler:(BookSelectCompleted)bookSelectCompleted
{
    self.bookSelectCompleted = bookSelectCompleted;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions
- (IBAction)closeBtnAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISarchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"YJ << cancel btn clicked");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
    
    NSLog(@"YJ << search btn clicked");
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setValue:self.searchBar.text forKey:@"query"];
    [dataDic setValue:[NSString stringWithFormat:@"%i", SEARCH_COUNT_ONCE] forKey:@"display"];
    [dataDic setValue:[NSString stringWithFormat:@"%i", 1] forKey:@"start"];
    [dataDic setValue:@"sim" forKey:@"sort"];
    [[AdminConnectionManager connManager] sendRequest:API_SEARCH_BOOK dataInfo:dataDic success:^(id responseData) {
        NSDictionary *chaDic = [responseData objectForKey:@"channel"];
        if (responseData && chaDic) {
            searchArr = [chaDic objectForKey:@"item"];
            searchIndex = [[chaDic objectForKey:@"start"] integerValue];
            totalCount = [[chaDic objectForKey:@"total"] integerValue];
            NSLog(@"YJ << book search data : %@", searchArr);
            [self.collectionView reloadData];
        }
    } failure:^(NSError *error, NSString *serverFault) {
        
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

#pragma mark - UICollectionViewDataSource
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"BookSearchCollectionViewCell";
    BookSearchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
    }
    
    NSDictionary *dic = searchArr[indexPath.item];
    if (dic) {
        
        NSString *style = @"<meta charset=\"UTF-8\"><style> body { font-family: 'HelveticaNeue'; font-size: 15px; } b {font-family: 'MarkerFelt-Wide'; }</style>";
        NSString *bTitle = [NSString stringWithFormat:@"%@%@", style, [dic objectForKey:@"title"]];
        NSDictionary *options = @{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType };
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithData:[bTitle dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:nil error:nil];
        NSString *strTitle = [NSString stringWithFormat:@"%@ (%@)", [attrString string], [dic objectForKey:@"pubdate"]];
        NSString *strDesc = [NSString stringWithFormat:@"%@ | %@", [dic objectForKey:@"author"], [dic objectForKey:@"publisher"]];
        
        [cell.titleLabel setText:strTitle];
        [cell.descLabel setText:strDesc];
        [cell.coverImgView setImage:[UIImage imageNamed:@"icon_noimg"]];
        [cell.coverImgView sd_setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"image"]]];
    }

    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return searchArr.count;
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"YJ << select collectionview cell");
    if (self.bookSelectCompleted) {
        NSDictionary *dic = searchArr[indexPath.item];
        self.bookSelectCompleted(dic);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.frame), 50.0f);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        NSLog(@"YJ << scrollview did end deceleratgin");
        if ((searchIndex * SEARCH_COUNT_ONCE) < totalCount) {
            NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
            [dataDic setValue:self.searchBar.text forKey:@"query"];
            [dataDic setValue:[NSString stringWithFormat:@"%i", SEARCH_COUNT_ONCE] forKey:@"display"];
            [dataDic setValue:[NSString stringWithFormat:@"%i", (searchIndex+1)] forKey:@"start"];
            [dataDic setValue:@"sim" forKey:@"sort"];
            [[AdminConnectionManager connManager] sendRequest:API_SEARCH_BOOK dataInfo:dataDic success:^(id responseData) {
                NSDictionary *chaDic = [responseData objectForKey:@"channel"];
                if (responseData && chaDic) {
                    [searchArr addObjectsFromArray:[chaDic objectForKey:@"item"]];
//                    [searchArr addObject:[chaDic objectForKey:@"item"]];
                    searchIndex = [[chaDic objectForKey:@"start"] integerValue];
                    totalCount = [[chaDic objectForKey:@"total"] integerValue];
                    NSLog(@"YJ << book search data : %@", searchArr);
                    [self.collectionView reloadData];
                }
            } failure:^(NSError *error, NSString *serverFault) {
                
            }];
        }
    }
}

@end
