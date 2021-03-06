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
    
    [self setNaviBarType:BAR_EDIT title:NSLocalizedString(@"Bookmark", @"") image:nil];
    
    coreData = [CoreDataAccess sharedInstance];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.quoteFetchedResultsController = coreData.quoteFetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.quoteFetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
    self.quoteManagedObjectContext = coreData.quoteManagedObjectContext;
    
    if (self.book) {
        [self.titleLabel setText:self.book.title];
        [self.authorLabel setText:self.book.author];
        if (self.book.quotes.count > 0) {
            NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
            NSArray *quoteArr = [self.book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
            
            Quote *quote;
            for (int i = 0; i < quoteArr.count; i++) {
                Quote *preQuote = quoteArr[i];
                if (preQuote.index == self.quoteIndex) {
                    quote = preQuote;
                    self.indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                }
            }
//            Quote *quote = quoteArr[self.indexPath.item];
            NSAttributedString *attrQuote = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)quote.data]; // nsdate -> nsattributedstring
            
            [self.textView.textStorage setAttributedString:attrQuote];
            [self.textView setContentInset:UIEdgeInsetsZero];
            self.textView.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5);
            self.textView.textContainer.lineFragmentPadding = 0;
        }
    }
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.managedObjectContext = nil;
    self.quoteManagedObjectContext = nil;
    self.fetchedResultsController = nil;
    self.quoteFetchedResultsController = nil;
    
    [coreData coreDataInitialize];
    self.fetchedResultsController = coreData.fetchedResultsController;
    self.fetchedResultsController.delegate = self;
    self.quoteFetchedResultsController = coreData.quoteFetchedResultsController;
    self.quoteFetchedResultsController.delegate = self;
    self.managedObjectContext = coreData.managedObjectContext;
    self.quoteManagedObjectContext = coreData.quoteManagedObjectContext;
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
//            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//            [appDelegate.alertWindow makeKeyAndVisible];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete", @"") message:NSLocalizedString(@"Do you really want to delete?", @"") preferredStyle:UIAlertControllerStyleActionSheet];
            
            NSString *strFirst = NSLocalizedString(@"Deleting", @"");
            NSString *strSecond = NSLocalizedString(@"Cancel", @"");
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//                [appDelegate.alertWindow setHidden:YES];
                
                if (self.bookmarkDeleteCompleted) {
                    [self popController:YES];
                    self.bookmarkDeleteCompleted(self.indexPath);
                }
            }];
            UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                [appDelegate.alertWindow setHidden:YES];
                
                [self dismissController:alert animated:YES];
            }];
            
            [alert addAction:firstAction];
            [alert addAction:secondAction];
            [self presentController:alert animated:YES];
//            [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
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
                    NSAttributedString *attrQuote = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)quote.data]; // nsdate -> nsattributedstring
                    
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
    
    NSFetchRequest <Quote *> *fetchRequest = Quote.fetchRequest;
    
    [self.quoteManagedObjectContext performBlock:^{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        NSArray *quoteArr = [self.book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        Quote *quote = quoteArr[self.indexPath.item];
        
        NSError * error;
        
        NSArray * resultArray = [self.quoteManagedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if([resultArray count]) {
            
            NSAttributedString *attrStr = [qDic objectForKey:@"mQuote"];
            NSData *attrData = [NSKeyedArchiver archivedDataWithRootObject:attrStr]; // nsdate -> nsattributedstring
            
            quote.modifyDate = [NSDate date];
            
            if (attrStr) {
                quote.data = attrData;
                quote.strData = attrStr.string;
            } else {
                quote.data = @"";
                quote.strData = @"";
            } 
            
            [self.quoteManagedObjectContext save:&error];
            
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
    
    if (controller == self.quoteFetchedResultsController) {
        NSLog(@"YJ << NSFetchedResultsController - controllerWillChangeContent - BookmarkDetailViewController");
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    if (controller == self.quoteFetchedResultsController) {
        NSLog(@"YJ << NSFetchedResultsController - didChangeSection - BookmarkDetailViewController");
        
        switch(type) {
            case NSFetchedResultsChangeInsert:
                NSLog(@"YJ << quoteFetchedResultsController - NSFetchedResultChangeInsert");
                break;
            case NSFetchedResultsChangeDelete:
                NSLog(@"YJ << quoteFetchedResultsController - NSFetchedResultsChangeDelete");
                break;
            default:
                return;
        }
    }
}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(nonnull id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    
    if (controller == self.quoteFetchedResultsController) {
        NSLog(@"YJ << NSFetchedResultsController - didChangeObject - BookmarkDetailViewController");
        
        switch(type) {
            case NSFetchedResultsChangeInsert: {
                break;
            }
            case NSFetchedResultsChangeDelete: {
                break;
            }
            case NSFetchedResultsChangeUpdate: {
                break;
            }
            case NSFetchedResultsChangeMove: {
                break;
            }
        }
    }
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if (controller == self.quoteFetchedResultsController) {
        NSLog(@"YJ << NSFetchedResultsController - controllerDidChangeContent - BookmarkDetailViewController");
    }
}


@end
