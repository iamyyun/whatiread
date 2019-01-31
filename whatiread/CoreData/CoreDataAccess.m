//
//  CoreDataAccess.m
//  whatiread
//
//  Created by Yunju on 2018. 5. 30..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "CoreDataAccess.h"

static CoreDataAccess *coreData = nil;

@interface CoreDataAccess () {
    
}

@end

@implementation CoreDataAccess

+ (void)removeInstance
{
    if( coreData != nil )
    {
        coreData = nil;
    }
}

#pragma mark - singleton object
+ (CoreDataAccess *)sharedInstance
{
    if (coreData == nil) {
        // object initialize
        coreData = [[CoreDataAccess alloc] init];
    }
    else {
    }
    
    return coreData;
}

#pragma mark - Core Data stack

//@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    NSLog(@"YJ << coreDataAccess persistentContainer");
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (SHAREDAPPDELEGATE.persistentContainer == nil) {
//            SHAREDAPPDELEGATE.persistentContainer = [[NSPersistentContainer alloc] initWithName:@"whatiread"];
            [SHAREDAPPDELEGATE.persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return SHAREDAPPDELEGATE.persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = SHAREDAPPDELEGATE.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

//- (NSURL *)applicationDocumentsDirectory
//{
//    return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.atsolutions.extension"];
//}

#pragma mark - Fetched results controller
- (NSFetchedResultsController <Book *> *)fetchedResultsController {
    if(_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    if(_managedObjectContext == nil) {
        _managedObjectContext = SHAREDAPPDELEGATE.persistentContainer.viewContext;
    }
    
    NSFetchRequest <Book *> * fetchRequest = Book.fetchRequest;
    
    [fetchRequest setFetchBatchSize:30];
    
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completeDate" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSFetchedResultsController <Book *> *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:@"MainBookList"];
    aFetchedResultsController.delegate = self;
    
    NSError * error = nil;
    
    if(![aFetchedResultsController performFetch:&error]) {
        abort();
    }
    
    _fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (NSFetchedResultsController <Quote *> *)quoteFetchedResultsController {
    if(_quoteFetchedResultsController != nil) {
        return _quoteFetchedResultsController;
    }
    
    if(_quoteManagedObjectContext == nil) {
        _quoteManagedObjectContext = SHAREDAPPDELEGATE.persistentContainer.viewContext;
    }
    
    NSFetchRequest <Quote *> * fetchRequest = Quote.fetchRequest;
    
    [fetchRequest setFetchBatchSize:30];
    
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSFetchedResultsController <Quote *> *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_quoteManagedObjectContext sectionNameKeyPath:nil cacheName:@"MainQuoteListMainBookList"];
    aFetchedResultsController.delegate = self;
    
    NSError * error = nil;
    
    if(![aFetchedResultsController performFetch:&error]) {
        abort();
    }
    
    _quoteFetchedResultsController = aFetchedResultsController;
    _quoteFetchedResultsController.delegate = self;
    
    return _quoteFetchedResultsController;
}

- (void) coreDataInitialize
{
    self.fetchedResultsController = nil;
    self.quoteFetchedResultsController = nil;
    self.managedObjectContext = nil;
    self.quoteManagedObjectContext = nil;
}

- (NSArray *)getAllBooks
{
    NSFetchRequest <Book *> * fetchRequest = Book.fetchRequest;
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completeDate" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSArray *bookArray = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return bookArray;
}

- (Book *)mapBook:(CKRecord *)record
{
    Book *book = [[Book alloc] initWithContext:self.managedObjectContext];
    book.index = [record[@"index"] intValue];
    book.title = record[@"title"];
    book.author = record[@"author"];
    book.publisher = record[@"publisher"];
    book.publishDate = (NSDate *)record[@"publishDate"];
    book.startDate = (NSDate *)record[@"startDate"];
    book.completeDate = (NSDate *)record[@"completeDate"];
    book.rate = [record[@"rate"] floatValue];
    book.review = record[@"review"];
    book.coverImg = (NSData *)record[@"coverImg"];
    book.modifyDate = (NSDate *)record[@"modifyDate"];
    book.isSearchMode = (BOOL)record[@"isSearchMode"];
    
    return book;
}

- (void)mapBook:(CKRecord *)record completionHandler:(BookDataCompletionHandler)handler
{
    Book *book = [[Book alloc] initWithContext:self.managedObjectContext];
    book.index = [record[@"index"] intValue];
    book.title = record[@"title"];
    book.author = record[@"author"];
    book.publisher = record[@"publisher"];
    book.publishDate = (NSDate *)record[@"publishDate"];
    book.startDate = (NSDate *)record[@"startDate"];
    book.completeDate = (NSDate *)record[@"completeDate"];
    book.rate = [record[@"rate"] floatValue];
    book.review = record[@"review"];
    book.coverImg = (NSData *)record[@"coverImg"];
    book.modifyDate = (NSDate *)record[@"modifyDate"];
    book.isSearchMode = (BOOL)record[@"isSearchMode"];
    
    handler (book);
    
//    NSMutableArray *quoteArr = [NSMutableArray array];
//    NSArray *refArr = [NSArray arrayWithArray:record[@"quotes"]];
//    for (int i = 0; i < refArr.count; i++) {
//        CKReference *reference = (CKReference *)refArr[i];
//        [CloudKitManager fetchQuoteWithRecordIdWithCompletionHandler:reference handler:^(NSArray *result, NSError *error) {
//            NSLog(@"YJ << quote record : %@", result[0]);
//
//            if (result && result.count > 0) {
//                CKRecord *record = (CKRecord *)result[0];
//                Quote *quote = [self mapQuote:record];
//                [quoteArr addObject:quote];
//
//                if (i == refArr.count-1) {
//                    if (quoteArr && quoteArr.count > 0) {
//                        // todo : nsset을 save 하는 방법!!
//                        NSSet<Quote *> *quoteSet = [NSSet setWithArray:quoteArr];
//                        book.quotes = quoteSet;
//
////                        if (!handler) return;
//
//                        handler (book);
////                        dispatch_sync(dispatch_get_main_queue(), ^{
////                            handler (book);
////                        });
//                    }
//                }
//            }
//        }];
////        CKRecord *record = [[CKRecord alloc] initWithRecordType:CKRecordTypeUserRecord recordID:reference.recordID];
//    }
//
////    return book;
}

- (void)mapQuote:(CKRecord *)record completionHandler:(QuoteDataCompletionHandler)handler
{
    Quote *quote = [[Quote alloc] initWithContext:self.quoteManagedObjectContext];
    quote.index = [record[@"index"] intValue];
    quote.data = (NSData *)record[@"data"];
    quote.date = (NSDate *)record[@"date"];
    quote.pageNum = [record[@"pageNum"] intValue];
    quote.strData = record[@"strData"];
    
    //book
    CKReference *reference = (CKReference *)record[@"book"];
    [CloudKitManager fetchBookWithRecordIdWithCompletionHandler:reference handler:^(NSArray *result, NSError *error) {
        NSLog(@"YJ << book record : %@", result[0]);
        
        if (result && result.count > 0) {
            CKRecord *record = (CKRecord *)result[0];
            Book *book = [self mapBook:record];
            quote.book = book;
            
            handler (quote);
        }
    }];
}

- (Quote *)mapQuote:(CKRecord *)record
{
    Quote *quote = [[Quote alloc] initWithContext:self.quoteManagedObjectContext];
    quote.index = [record[@"index"] intValue];
    quote.data = (NSData *)record[@"data"];
    quote.date = (NSDate *)record[@"date"];
    quote.pageNum = [record[@"pageNum"] intValue];
    quote.strData = record[@"strData"];
    
    // book
//    CKReference *reference
    
    return quote;
}

@end
