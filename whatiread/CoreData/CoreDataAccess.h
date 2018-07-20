//
//  CoreDataAccess.h
//  whatiread
//
//  Created by Yunju on 2018. 5. 30..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "whatiread+CoreDataModel.h"

@interface CoreDataAccess : NSObject <NSFetchedResultsControllerDelegate>

+ (CoreDataAccess *)sharedInstance;
+ (void)removeInstance;

//@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (strong, nonatomic) NSFetchedResultsController <Book *> * fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;

- (void) coreDataInitialize;

@end
