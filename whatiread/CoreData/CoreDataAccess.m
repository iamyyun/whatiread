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
    book.createDate = (NSDate *)record[@"createDate"];
    book.modifyDate = (NSDate *)record[@"modifyDate"];
    book.isSearchMode = record[@"isSearchMode"];
    
    handler (book);
}

- (void)mapQuote:(CKRecord *)record completionHandler:(QuoteDataCompletionHandler)handler
{
    Quote *quote = [[Quote alloc] initWithContext:self.managedObjectContext];
    quote.index = [record[@"index"] intValue];
    quote.data = (NSData *)record[@"data"];
    quote.createDate = (NSDate *)record[@"createDate"];
    quote.modifyDate = (NSDate *)record[@"modifyDate"];
    quote.pageNum = [record[@"pageNum"] intValue];
    quote.strData = record[@"strData"];
    
    handler (quote);
}

@end
