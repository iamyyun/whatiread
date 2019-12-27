//
//  CloudKitManager.h
//  whatiread
//
//  Created by Yunju on 2018. 9. 19..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CloudKitCompletionHandler)(NSArray *results, NSError *error);

@interface CloudKitManager : NSObject

+(BOOL)isiCloudAccountIsSignedIn;
+(BOOL)isiCloudStatusEnabled;

+(void)fetchAllBooksWithCompletionHandler:(CloudKitCompletionHandler)handler;
+(void)fetchAllQuotesWithCompletionHandler:(CloudKitCompletionHandler)handler;

+(void)fetchBookWithRecordReferenceWithCompletionHandler:(CKReference *)bookRef handler:(CloudKitCompletionHandler)handler;
+(void)fetchQuoteWithRecordReferenceWithCompletionHandler:(CKReference *)quoteRef handler:(CloudKitCompletionHandler)handler;

+(void)createBookRecord:(NSArray *)bookArray completionHandler:(CloudKitCompletionHandler)handler;
+(void)createQuoteRecord:(NSArray *)quoteArray completionHandler:(CloudKitCompletionHandler)handler;

+(void)removeBookRecord:(NSArray *)bookArray completionHandler:(CloudKitCompletionHandler)handler;
+(void)removeQuoteRecord:(NSArray *)quoteArray completionHandler:(CloudKitCompletionHandler)handler;

@end
