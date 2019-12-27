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
#import <CloudKit/CloudKit.h>

typedef void (^BookDataCompletionHandler)(Book *book);
typedef void (^QuoteDataCompletionHandler)(Quote *quote);

@interface CoreDataAccess : NSObject <NSFetchedResultsControllerDelegate>

+ (CoreDataAccess *)sharedInstance;
+ (void)removeInstance;

@property (strong, nonatomic) NSFetchedResultsController <Book *> *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController <Quote *> *quoteFetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *quoteManagedObjectContext;

- (void) coreDataInitialize;
- (NSArray *)getAllBooks;

- (void)mapBook:(CKRecord *)record completionHandler:(BookDataCompletionHandler)handler;
- (void)mapQuote:(CKRecord *)record completionHandler:(QuoteDataCompletionHandler)handler;

@end
