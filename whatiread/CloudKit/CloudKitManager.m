//
//  CloudKitManager.m
//  whatiread
//
//  Created by Yunju on 2018. 9. 19..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "CloudKitManager.h"
#import <CloudKit/CloudKit.h>
#import <UIKit/UIKit.h>
#import "whatiread+CoreDataModel.h"

NSString * const kBooksRecord = @"Book";
NSString * const kQuotesRecord = @"Quote";

@implementation CloudKitManager

#pragma mark - iCloud
+(BOOL)isiCloudAccountIsSignedIn {
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    if (token) {
        NSLog(@"YJ << iCloud is signed in with token %@", token);
        return YES;
    }
    NSLog(@"YJ << iCloud is not signed in with token");
    return NO;
}

+(BOOL)isiCloudStatusEnabled {
    
    __block BOOL isEnable = NO;
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * _Nullable error) {
        if (!error) {
            if (accountStatus == CKAccountStatusAvailable) {
                isEnable = YES;
            }
        }
    }];
    return isEnable;
}

#pragma mark - Database
+ (CKDatabase *)publicCloudDatabase {
    return [[CKContainer defaultContainer] publicCloudDatabase];
}

+ (CKDatabase *)privateCloudDatabase {
    return [[CKContainer defaultContainer] privateCloudDatabase];
}

+(void)fetchAllBooksWithCompletionHandler:(CloudKitCompletionHandler)handler {
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Book" predicate:predicate];
    
    [[self publicCloudDatabase] performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!handler) return;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            handler (results, error);
        });
    }];
}

+(void)fetchAllQuotesWithCompletionHandler:(CloudKitCompletionHandler)handler {
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Quote" predicate:predicate];
    
    [[self publicCloudDatabase] performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!handler) return;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            handler (results, error);
        });
    }];
}

+(void)fetchBookWithRecordReferenceWithCompletionHandler:(CKReference *)bookRef handler:(CloudKitCompletionHandler)handler {
    
    NSMutableArray *bookArr = [NSMutableArray array];
    
    [[self publicCloudDatabase] fetchRecordWithID:bookRef.recordID completionHandler:^(CKRecord *record, NSError *error) {
        if (!handler) return;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [bookArr addObject:record];
            handler (bookArr, error);
        });
    }];
}

+(void)fetchQuoteWithRecordReferenceWithCompletionHandler:(CKReference *)quoteRef handler:(CloudKitCompletionHandler)handler {
    
    NSMutableArray *quoteArr = [NSMutableArray array];
    
    [[self publicCloudDatabase] fetchRecordWithID:quoteRef.recordID completionHandler:^(CKRecord *record, NSError *error) {
        if (!handler) return;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [quoteArr addObject:record];
            handler (quoteArr, error);
        });
    }];
}

+(void)createBookRecord:(NSArray *)bookArray completionHandler:(CloudKitCompletionHandler)handler {
    
    for (int i = 0; i < bookArray.count; i++) {
        NSArray *keys = [[[bookArray[i] entity] attributesByName] allKeys];
        NSDictionary *dict = [bookArray[i] dictionaryWithValuesForKeys:keys];
        
        // get qutes data
        NSMutableArray *muQuoteRefArr = [NSMutableArray array];
        Book *book = (Book *)bookArray[i];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        NSArray *quoteArr = [book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        for (int i = 0; i < quoteArr.count; i++) {
            Quote *quote = (Quote *)quoteArr[i];
            
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyyMMddHHssmm"];
            NSString *strDate = [format stringFromDate:(NSDate *)quote.createDate];
            CKRecordID *recordId = [[CKRecordID alloc] initWithRecordName:strDate];
            CKReference *quoteReference = [[CKReference alloc] initWithRecordID:recordId action:CKReferenceActionNone];
            [muQuoteRefArr addObject:quoteReference];
        }
        
        CKRecordID *recordId = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%@", [dict objectForKey:@"index"]]];
        CKRecord *record = [[CKRecord alloc] initWithRecordType:kBooksRecord recordID:recordId];
        record[@"quotes"] = muQuoteRefArr;
        
        [[dict allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            id value = dict[key];
            if (value == nil || value == [NSNull null]) {
                
            } else {
                record[key] = dict[key];
            }
        }];
        
        [[self publicCloudDatabase] saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
            if (!handler) return;
            
            if (i == bookArray.count-1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler (nil, error);
                });
            }
        }];
    }
}

+(void)createQuoteRecord:(NSArray *)quoteArray completionHandler:(CloudKitCompletionHandler)handler {
    for (int i = 0; i < quoteArray.count; i++) {
        NSArray *keys = [[[quoteArray[i] entity] attributesByName] allKeys];
        NSDictionary *dict = [quoteArray[i] dictionaryWithValuesForKeys:keys];
        
        // get book data
        Quote *quote = (Quote *)quoteArray[i];
        Book *book = (Book *)quote.book;
        CKRecordID *bookRecordId = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%lld", book.index]];
        CKReference *bookReference = [[CKReference alloc] initWithRecordID:bookRecordId action:CKReferenceActionNone];
        
        // Quote
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyyMMddHHssmm"];
        NSString *strDate = [format stringFromDate:(NSDate *)[dict objectForKey:@"createDate"]];
        CKRecordID *recordId = [[CKRecordID alloc] initWithRecordName:strDate];
        CKRecord *record = [[CKRecord alloc] initWithRecordType:kQuotesRecord recordID:recordId];
        record[@"book"] = bookReference;
        
        [[dict allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            id value = dict[key];
            if (value == nil || value == [NSNull null]) {
                
            } else {
                record[key] = dict[key];
            }
        }];
        
        [[self publicCloudDatabase] saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
            if (!handler) return;
            
            if (i == quoteArray.count-1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler (nil, error);
                });
            }
        }];
    }
}

+(void)removeBookRecord:(NSArray *)bookArray completionHandler:(CloudKitCompletionHandler)handler {
    
    for (int i = 0; i < bookArray.count; i++) {
        CKRecord *record = bookArray[i];
        [[self publicCloudDatabase] deleteRecordWithID:record.recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
            if (!handler) return;

            if (i == bookArray.count-1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler (nil, error);
                });
            }
        }];
    }
}

+(void)removeQuoteRecord:(NSArray *)quoteArray completionHandler:(CloudKitCompletionHandler)handler {

    for (int i = 0; i < quoteArray.count; i++) {
        CKRecord *record = quoteArray[i];
        [[self publicCloudDatabase] deleteRecordWithID:record.recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
            if (!handler) return;
            
            if (i == quoteArray.count-1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler (nil, error);
                });
            }
        }];
    }
}

@end
