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

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    NSLog(@"YJ << coreDataAccess persistentContainer");
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"whatiread"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
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
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
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
        _managedObjectContext = self.persistentContainer.viewContext;
    }
    
    NSFetchRequest <Book *> * fetchRequest = Book.fetchRequest;
    
    [fetchRequest setFetchBatchSize:30];
    
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"accntIndex" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSFetchedResultsController <Book *> *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:@"MainAccntList"];
    aFetchedResultsController.delegate = self;
    
    NSError * error = nil;
    
    if(![aFetchedResultsController performFetch:&error]) {
        abort();
    }
    
    _fetchedResultsController = aFetchedResultsController;
    
    return _fetchedResultsController;
}

@end
