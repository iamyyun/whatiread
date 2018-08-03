//
//  BookSearchViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 7. 23..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "BookSearchViewController.h"
#import "BookSearchCollectionViewCell.h"
#import "AddBookViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MTBBarcodeScanner.h"

#define SEARCH_COUNT_ONCE  20

@interface BookSearchViewController () <UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate> {
    NSMutableArray *searchArr;
    
    NSInteger searchIndex;
    NSInteger totalCount;
    
    MTBBarcodeScanner *scanner;
}

@end

@implementation BookSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    searchArr = [NSMutableArray array];
    
    [self.searchBar setImage:[UIImage imageNamed:@"btn_barcode"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    
    [self.collectionView setAllowsSelection:YES];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BookSearchCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"BookSearchCollectionViewCell"];
    
    scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.previewView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBookSearchHandler:(BookSelectCompleted)bookSelectCompleted
{
    self.bookSelectCompleted = bookSelectCompleted;
}

- (NSString *)makeMetaToString:(NSString *)strMeta {
    NSString *strResult = @"";
    NSString *style = @"<meta charset=\"UTF-8\"><style> body { font-family: 'HelveticaNeue'; font-size: 15px; } b {font-family: 'MarkerFelt-Wide'; }</style>";
    NSString *meta = [NSString stringWithFormat:@"%@%@", style, strMeta];
    NSDictionary *options = @{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithData:[meta dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:nil error:nil];
    strResult = [NSString stringWithFormat:@"%@", [attrString string]];
    
    return strResult;
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

- (IBAction)scanCloseBtnAction:(id)sender {
    [self.scanView setHidden:YES];
    [scanner stopScanning];
}

- (IBAction)swtichBtnAction:(id)sender {
    [scanner flipCamera];
}

- (IBAction)flashBtnAction:(id)sender {
    if (scanner.torchMode == MTBTorchModeOff) {
        scanner.torchMode = MTBTorchModeOn;
        [self.flashBtn setImage:[UIImage imageNamed:@"btn_flash_on"] forState:UIControlStateNormal];
    } else {
        scanner.torchMode = MTBTorchModeOff;
        [self.flashBtn setImage:[UIImage imageNamed:@"btn_flash_off"] forState:UIControlStateNormal];
    }
}

- (void) barcodeBtnAction:(id)sender {
    
}

#pragma mark - API Request
- (void)requestSearchBook {
    [IndicatorUtil startProcessIndicator];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:self.searchBar.text forKey:@"query"];
    [dataDic setObject:[NSString stringWithFormat:@"%i", SEARCH_COUNT_ONCE] forKey:@"display"];
    [dataDic setObject:[NSString stringWithFormat:@"%i", 1] forKey:@"start"];
    [dataDic setObject:@"sim" forKey:@"sort"];
    [[AdminConnectionManager connManager] sendRequest:API_SEARCH_BOOK dataInfo:dataDic success:^(id responseData) {
        NSDictionary *chaDic = [responseData objectForKey:@"channel"];
        if (responseData && chaDic) {
            searchArr = [chaDic objectForKey:@"item"];
            searchIndex = [[chaDic objectForKey:@"start"] integerValue];
            totalCount = [[chaDic objectForKey:@"total"] integerValue];
            NSLog(@"YJ << book search data : %@", searchArr);
            [self.collectionView reloadData];
            [IndicatorUtil stopProcessIndicator];
        }
    } failure:^(NSError *error, NSString *serverFault) {
        
    }];
}

- (void)requestSearchBookDetail:(NSString *)strBarcode {
    [IndicatorUtil startProcessIndicator];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
//    [dataDic setObject:self.searchBar.text forKey:@"query"];
//    [dataDic setObject:[NSString stringWithFormat:@"%i", SEARCH_COUNT_ONCE] forKey:@"display"];
//    [dataDic setObject:[NSString stringWithFormat:@"%i", 1] forKey:@"start"];
//    [dataDic setObject:@"sim" forKey:@"sort"];
    [dataDic setObject:strBarcode forKey:@"d_isbn"];
    [[AdminConnectionManager connManager] sendRequest:API_SEARCH_BOOK_DETAIL dataInfo:dataDic success:^(id responseData) {
        NSDictionary *chaDic = [responseData objectForKey:@"channel"];
        if (responseData && chaDic) {
            totalCount = [[chaDic objectForKey:@"total"] integerValue];
            if (totalCount == 0) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"해당하는 책 정보가 없습니다." message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                [alert addAction:okAction];
                [self presentController:alert animated:YES];
            } else {
                if (self.bookSelectCompleted) {
                    NSDictionary *dic = [chaDic objectForKey:@"item"];
                    self.bookSelectCompleted(dic);
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
            [IndicatorUtil stopProcessIndicator];
        }
    } failure:^(NSError *error, NSString *serverFault) {
        
    }];
}

#pragma mark - UISarchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar setText:@""];
    [self.view endEditing:YES];
    searchArr = [NSMutableArray array];
    [self.collectionView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
    [self requestSearchBook];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    [self.scanView setHidden:NO];
    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        if (success) {
            
            NSError *error = nil;
            [scanner startScanningWithResultBlock:^(NSArray *codes) {
                AVMetadataMachineReadableCodeObject *code = [codes firstObject];
                NSLog(@"Found code: %@", code.stringValue);
                
                [self.scanView setHidden:YES];
                [scanner stopScanning];
                
                [self requestSearchBookDetail:code.stringValue];
            } error:&error];
            
        } else {
            // The user denied access to the camera
        }
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
        NSString *strTitle = [NSString stringWithFormat:@"%@ (%@)", [self makeMetaToString:[dic objectForKey:@"title"]], [dic objectForKey:@"pubdate"]];
        NSString *strDesc = [NSString stringWithFormat:@"%@ | %@", [self makeMetaToString:[dic objectForKey:@"author"]], [dic objectForKey:@"publisher"]];
        
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
    BookSearchCollectionViewCell *cell = (BookSearchCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell.checkImgView setHidden:NO];
    
    NSDictionary *dic = searchArr[indexPath.item];
    NSString *strTitle = [dic objectForKey:@"title"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"[%@] 을(를) 나의 책장에 추가 하시겠습니까?", [self makeMetaToString:strTitle]] message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [cell.checkImgView setHidden:YES];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.bookSelectCompleted) {
            NSDictionary *dic = searchArr[indexPath.item];
            self.bookSelectCompleted(dic);
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentController:alert animated:YES];
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
            [IndicatorUtil startProcessIndicator];
            NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
            [dataDic setObject:self.searchBar.text forKey:@"query"];
            [dataDic setObject:[NSString stringWithFormat:@"%i", SEARCH_COUNT_ONCE] forKey:@"display"];
            [dataDic setObject:[NSString stringWithFormat:@"%i", (searchIndex+1)] forKey:@"start"];
            [dataDic setObject:@"sim" forKey:@"sort"];
            [[AdminConnectionManager connManager] sendRequest:API_SEARCH_BOOK dataInfo:dataDic success:^(id responseData) {
                NSDictionary *chaDic = [responseData objectForKey:@"channel"];
                if (responseData && chaDic) {
                    [searchArr addObjectsFromArray:[chaDic objectForKey:@"item"]];
//                    [searchArr addObject:[chaDic objectForKey:@"item"]];
                    searchIndex = [[chaDic objectForKey:@"start"] integerValue];
                    totalCount = [[chaDic objectForKey:@"total"] integerValue];
                    NSLog(@"YJ << book search data : %@", searchArr);
                    [self.collectionView reloadData];
                    [IndicatorUtil stopProcessIndicator];
                }
            } failure:^(NSError *error, NSString *serverFault) {
                
            }];
        }
    }
}

@end
