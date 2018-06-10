//
//  BookmarkViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 6. 4..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "BookmarkViewController.h"
#import "BookmarkCollectionViewCell.h"
#import "AddBookmarkViewController.h"

@interface BookmarkViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation BookmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNaviBarType:BAR_NORMAL];
    
    [self.collectionView setAllowsSelection:YES];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BookmarkCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"BookmarkCollectionViewCell"];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSInteger bookCount = [sectionInfo numberOfObjects];
    if (bookCount > 0) {
        [self.collectionView setHidden:NO];
        [self.emptyView setHidden:YES];
    } else {
        [self.collectionView setHidden:YES];
        [self.emptyView setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions
// add bookmark btn action
- (IBAction)addBtnAction:(id)sender {
    AddBookmarkViewController *vc = [[AddBookmarkViewController alloc] init];
    [self pushController:vc animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"BookmarkCollectionViewCell";
    BookmarkCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
    }
    
    //    PHAsset *asset = fetchResult[indexPath.item];
    //    NSLog(@"YJ << image creation date : %@", asset.creationDate);
    //    [imgManager requestImageForAsset:asset targetSize:cell.imgView.frame.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info)
    //     {
    //         NSLog(@"YJ << requestImageForAsset");
    //         [cell.imgView setImage:result];
    //     }];
//    [cell.imgView setImage:imgArr[indexPath.row]];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
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
    __block UIImage *dImg = [[UIImage alloc]init];
    
//    PHAsset *asset = fetchResult[indexPath.item];
//    [imgManager requestImageForAsset:asset targetSize:self.view.frame.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info)
//     {
//         dImg = result;
//     }];
}
@end
