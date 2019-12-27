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
    
    UITapGestureRecognizer *bgTap;
}

@end

@implementation BookSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // localized language
    [self.headerLabel setText:NSLocalizedString(@"Search Book", @"")];
    [self.searchBar setPlaceholder:NSLocalizedString(@"Please enter the book title.", @"")];
    [self.noResultLabel setText:NSLocalizedString(@"There is no result.", @"")];
    
    searchArr = [NSMutableArray array];
    
    [self.searchBar setImage:[UIImage imageNamed:@"btn_barcode"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    
    [self.collectionView setAllowsSelection:YES];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BookSearchCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"BookSearchCollectionViewCell"];
    
    scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.previewView];
    scanner.allowTapToFocus = YES;
    
    // Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShowNote:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHideNote:) name:UIKeyboardWillHideNotification object:self.view.window];
    bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(writeFinished)];
    
    // top Constraint
    if ([self isiPad]) {
        self.topConstraint.constant = 20.f;
    } else {
        if ([self isAfteriPhoneX]) {
            self.topConstraint.constant = 44.f;
        } else {
            self.topConstraint.constant = 20.f;
        }
    }
    [self updateViewConstraints];
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

- (void) writeFinished {
    [self.view endEditing:YES];
}

#pragma mark - Actions
- (IBAction)closeBtnAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)scanCloseBtnAction:(id)sender {
    [self.scanView setHidden:YES];
    [scanner stopScanning];
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

#pragma mark - API Request
- (void)requestSearchBook {
    [IndicatorUtil startProcessIndicator];
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:self.searchBar.text forKey:@"query"];
    [dataDic setObject:[NSString stringWithFormat:@"%i", SEARCH_COUNT_ONCE] forKey:@"display"];
    [dataDic setObject:[NSString stringWithFormat:@"%i", 1] forKey:@"start"];
    [dataDic setObject:@"sim" forKey:@"sort"];
    
    // request SEARCH BOOK
    [[AdminConnectionManager connManager] sendRequest:API_SEARCH_BOOK dataInfo:dataDic success:^(id responseData) {
        NSDictionary *chaDic = [responseData objectForKey:@"channel"];
        if (responseData && chaDic) {
            NSInteger count = [[chaDic objectForKey:@"display"] integerValue];
            
            NSMutableArray *muArr = [NSMutableArray arrayWithArray:[chaDic objectForKey:@"item"]];
            for (int i = 0; i < count; i++) {
                NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:muArr[i]];
                NSString *title = [self makeMetaToString:[muDic objectForKey:@"title"]];
                NSString *author = [self makeMetaToString:[muDic objectForKey:@"author"]];
                
                [muDic setObject:title forKey:@"title"];
                [muDic setObject:author forKey:@"author"];
                
                [muArr replaceObjectAtIndex:i withObject:muDic];
            }
            
            if (count == 1) {
                searchArr = @[muArr];
            } else {
                searchArr = muArr;
            }
            
            searchIndex = [[chaDic objectForKey:@"start"] integerValue];
            totalCount = [[chaDic objectForKey:@"total"] integerValue];
            
            if (!searchArr || searchArr.count <= 0) {
                [self.collectionView setHidden:YES];
                [self.emptyView setHidden:NO];
            } else {
                [self.collectionView setHidden:NO];
                [self.emptyView setHidden:YES];
            }
            
            [self.collectionView reloadData];
            
            [IndicatorUtil stopProcessIndicator];
        }
    } failure:^(NSError *error, NSString *serverFault) {
        [IndicatorUtil stopProcessIndicator];
        [self.view makeToast:NSLocalizedString(@"Network Error", @"")];
    }];
}

- (void)requestSearchBookDetail:(NSString *)strBarcode {
    [IndicatorUtil startProcessIndicator];
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:strBarcode forKey:@"d_isbn"];
    
    // request BOOK DETAIL
    [[AdminConnectionManager connManager] sendRequest:API_SEARCH_BOOK_DETAIL dataInfo:dataDic success:^(id responseData) {
        NSDictionary *chaDic = [responseData objectForKey:@"channel"];
        if (responseData && chaDic) {
            totalCount = [[chaDic objectForKey:@"total"] integerValue];
            if (totalCount == 0) {
//                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//                [appDelegate.alertWindow makeKeyAndVisible];
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"There is no result.", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                    [appDelegate.alertWindow setHidden:YES];
                }];
                [alert addAction:okAction];
                [self presentController:alert animated:YES];
//                [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];

            } else {
                
                NSDictionary *dic = [chaDic objectForKey:@"item"];
                NSString *strTitle = [dic objectForKey:@"title"];
                
//                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//                [appDelegate.alertWindow makeKeyAndVisible];
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Do you want to add [%@] in Bookshelf?", @""), [self makeMetaToString:strTitle]] message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//                    [appDelegate.alertWindow setHidden:YES];
                }];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                    [appDelegate.alertWindow setHidden:YES];
                    
                    if (self.bookSelectCompleted) {
                        self.bookSelectCompleted(dic);
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
                [alert addAction:cancelAction];
                [alert addAction:okAction];
                [self presentController:alert animated:YES];
//                [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            }
            
            [IndicatorUtil stopProcessIndicator];
        }
    } failure:^(NSError *error, NSString *serverFault) {
        [IndicatorUtil stopProcessIndicator];
        [self.view makeToast:NSLocalizedString(@"Network Error", @"")];
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
    [self writeFinished];
    
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
            [self.scanView setHidden:YES];
            [scanner stopScanning];
            
//            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//            [appDelegate.alertWindow makeKeyAndVisible];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Camera Access Denied", @"") message:NSLocalizedString(@"App needs camera access.\nTo do this, go to Settings > Privacy > Camera on your device.", @"") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                [appDelegate.alertWindow setHidden:YES];
            }];
            [alert addAction:okAction];
            [self presentController:alert animated:YES];
//            [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
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
        NSString *strTitle = [NSString stringWithFormat:@"%@ (%@)", [dic objectForKey:@"title"], [dic objectForKey:@"pubdate"]];
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
    BookSearchCollectionViewCell *cell = (BookSearchCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [cell.checkImgView setHidden:NO];
    
    NSDictionary *dic = searchArr[indexPath.item];
    NSString *strTitle = [dic objectForKey:@"title"];
    
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate.alertWindow makeKeyAndVisible];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Do you want to add [%@] in Bookshelf?", @""), [self makeMetaToString:strTitle]] message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//        [appDelegate.alertWindow setHidden:YES];
        
        [cell.checkImgView setHidden:YES];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [appDelegate.alertWindow setHidden:YES];
        
        if (self.bookSelectCompleted) {
            NSDictionary *dic = searchArr[indexPath.item];
            self.bookSelectCompleted(dic);
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self presentController:alert animated:YES];
//    [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.frame), 50.0f);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        
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
                    NSInteger count = [[chaDic objectForKey:@"display"] integerValue];
                    
                    NSMutableArray *muArr = [NSMutableArray arrayWithArray:[chaDic objectForKey:@"item"]];
                    for (int i = 0; i < count; i++) {
                        NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:muArr[i]];
                        NSString *title = [self makeMetaToString:[muDic objectForKey:@"title"]];
                        NSString *author = [self makeMetaToString:[muDic objectForKey:@"author"]];
                        
                        [muDic setObject:title forKey:@"title"];
                        [muDic setObject:author forKey:@"author"];
                        
                        [muArr replaceObjectAtIndex:i withObject:muDic];
                    }
                    
                    [searchArr addObjectsFromArray:muArr];
                    searchIndex = [[chaDic objectForKey:@"start"] integerValue];
                    totalCount = [[chaDic objectForKey:@"total"] integerValue];
                    
                    [self.collectionView reloadData];
                    
                    [IndicatorUtil stopProcessIndicator];
                }
            } failure:^(NSError *error, NSString *serverFault) {
                [IndicatorUtil stopProcessIndicator];
                [self.view makeToast:NSLocalizedString(@"Network Error", @"")];
            }];
        }
    }
}

#pragma mark - keyboard actions
- (void)handleKeyboardWillShowNote:(NSNotification *)notification
{
    [self.view addGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [self.view updateConstraints];
}

- (void)handleKeyboardWillHideNote:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [self.view updateConstraints];
}

@end
