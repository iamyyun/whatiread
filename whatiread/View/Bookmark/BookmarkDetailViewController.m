//
//  BookmarkDetailViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 8. 4..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "BookmarkDetailViewController.h"
#import "AddBookmarkViewController.h"

@interface BookmarkDetailViewController () <UITextViewDelegate> {
    CoreDataAccess *coreData;
}

@end

@implementation BookmarkDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNaviBarType:BAR_EDIT title:@"책갈피" image:nil];
    
    coreData = [CoreDataAccess sharedInstance];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
    
    if (self.book) {
        [self.titleLabel setText:self.book.title];
        [self.authorLabel setText:self.book.author];
        if (self.book.quotes.count > 0) {
            NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
            NSArray *quoteArr = [self.book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
            Quote *quote = quoteArr[self.indexPath.item];
            NSAttributedString *attrQuote = (NSAttributedString *)quote.data;
            
            [self.textView setAttributedText:attrQuote];
            [self.textView setContentInset:UIEdgeInsetsZero];
            self.textView.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5);
            self.textView.textContainer.lineFragmentPadding = 0;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.managedObjectContext = nil;
    self.fetchedResultsController = nil;
    
    [coreData coreDataInitialize];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// set block
- (void)setBookmarkDetailCompositionHandler:(Book *)book bookmarkDeleteCompleted:(BookmarkDeleteCompleted)bookmarkDeleteCompleted
{
    self.book = book;
    self.bookmarkDeleteCompleted = bookmarkDeleteCompleted;
}

#pragma mark - Navigation Actions
- (void)leftBarBtnClick:(id)sender {
    [self popController:YES];
}

- (void)rightBarBtnClick:(id)sender {
    switch ([sender tag]) {
        case BTN_TYPE_DELETE:
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete", @"") message:NSLocalizedString(@"Do you really want to delete?", @"") preferredStyle:UIAlertControllerStyleActionSheet];
            
            NSString *strFirst = NSLocalizedString(@"Deleting", @"");
            NSString *strSecond = NSLocalizedString(@"Cancel", @"");
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                if (self.bookmarkDeleteCompleted) {
                    self.bookmarkDeleteCompleted(self.indexPath);
                }
            }];
            UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self dismissController:alert animated:YES];
            }];
            
            [alert addAction:firstAction];
            [alert addAction:secondAction];
            [self presentController:alert animated:YES];
        }
            break;
        case BTN_TYPE_EDIT:
        {
            AddBookmarkViewController *addVC = [[AddBookmarkViewController alloc] init];
            addVC.isModifyMode = YES;
            addVC.indexPath = self.indexPath;
            addVC.book = self.book;
            [addVC setBookmarkCompositionHandler:self.book bookmarkCreateCompleted:nil bookmarkModifyCompleted:^(NSAttributedString *attrQuote, NSIndexPath *indexPath) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setObject:attrQuote forKey:@"mQuote"];
                [self modifyBookmark:self.book qDic:dic indexPath:indexPath completed:^(BOOL isResult) {
                        NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
                        NSArray *quoteArr = [self.book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
                        Quote *quote = quoteArr[self.indexPath.item];
                        NSAttributedString *attrQuote = (NSAttributedString *)quote.data;
                    
                        [self.textView setAttributedText:attrQuote];
                        [self.view layoutIfNeeded];
                }];
            }];
            [self pushController:addVC animated:YES];
        }
            break;
        default:
            break;
    }
}

// modify bookmark
- (void)modifyBookmark:(Book *)book qDic:(NSDictionary *)qDic indexPath:(NSIndexPath *)indexPath completed:(void (^)(BOOL isResult))completed {
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest <Quote *> *fetchRequest = Quote.fetchRequest;
    
    NSDate *now = [[NSDate alloc] init];
    
    [context performBlock:^{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        NSArray *quoteArr = [self.book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        Quote *quote = quoteArr[self.indexPath.item];
        
        NSError * error;
        
        NSArray * resultArray = [context executeFetchRequest:fetchRequest error:&error];
        
        if([resultArray count]) {
            
            NSAttributedString *attrStr = [qDic objectForKey:@"mQuote"];
            
            quote.date = [NSDate date];
            
            if (attrStr) {
                quote.data = attrStr;
                quote.strData = attrStr.string;
            } else {
                quote.data = @"";
                quote.strData = @"";
            }
            
            if ([qDic objectForKey:@"mImage"]) {
                NSData *imageData = UIImagePNGRepresentation([qDic objectForKey:@"mImage"]);
                quote.image = imageData;
            } else {
                quote.image = nil;
            }
            
            [context save:&error];
            
            if (!error) {
                if (completed) {
                    completed(YES);
                }
            }
            else {
                if (completed) {
                    completed(NO);
                }
            }
        }
        else {
            if (completed) {
                completed(NO);
            }
        }
    }];
}

#pragma mark - FetchedResultsController Delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
//            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            break;
        case NSFetchedResultsChangeDelete:
//            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            break;
        default:
            return;
    }
}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(nonnull id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    
    NSLog(@"YJ << section : %ld", newIndexPath.section);
    NSLog(@"YJ << item : %ld", newIndexPath.item);
    
    self.fetchedResultsController = nil;
    self.managedObjectContext = nil;
    
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
//    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
//    quoteArr = [self.book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
//
//    if (quoteArr && quoteArr.count > 0) {
//        [self.collectionView setHidden:NO];
//        [self.emptyView setHidden:YES];
//    } else {
//        [self.collectionView setHidden:YES];
//        [self.emptyView setHidden:NO];
//    }
//
//    [self.bmCountLabel setText:[NSString stringWithFormat:@"%ld", self.book.quotes.count]];
//    [self.collectionView reloadData];
}


@end
