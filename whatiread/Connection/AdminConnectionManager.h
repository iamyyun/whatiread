//
//  AdminConnectionManager.h
//  whatiread
//
//  Created by Yunju on 2018. 7. 23..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NETWORK_TIMEOUT         10.0

#define API_SEARCH_BOOK             @"v1/search/book.xml"
#define API_SEARCH_BOOK_DETAIL      @"v1/search/book_adv.xml"

typedef NS_ENUM(NSUInteger, CONNECTED_TYPE)
{
    CONNECTION_NONE = 0,
    CONNECTION_WIFI,
    CONNECTION_3G
};

typedef NS_ENUM(NSUInteger, CONTENT_TYPE)
{
    APPLICATION_CONTENT_TYPE = 0,
    MULTIPART_CONTENT_TYPE,
};

@interface AdminConnectionManager : NSObject

+ (AdminConnectionManager *) connManager;

#pragma mark - send reqeust
- (void) sendRequest:(NSString *)subUrl dataInfo:(NSDictionary *)dataInfo success:(void (^)(id responseData))success failure:(void (^)(NSError * error, NSString * serverFault))failure;

@end
