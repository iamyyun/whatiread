//
//  AdminConnectionManager.m
//  whatiread
//
//  Created by Yunju on 2018. 7. 23..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "AdminConnectionManager.h"
#import "Reachability.h"
#import "AFNetworking.h"

@interface AdminConnectionManager ()

@property (nonatomic, strong) AFHTTPSessionManager * operationManager;

@end

@implementation AdminConnectionManager

#pragma mark - connManager
+ (AdminConnectionManager *) connManager {
    static AdminConnectionManager * adminConnectionManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        adminConnectionManager = [[self alloc] init];
    });
    
    return adminConnectionManager;
}

#pragma mark - networkCondition
- (BOOL) networkCondition {
    Reachability * r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    BOOL internet;
    
    if((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        internet = NO;
    }
    else
    {
        internet = YES;
    }
    
#if defined(DEV)
    return YES;
#endif
    
    return internet;
}

#pragma mark - httpHeaderSetting
- (BOOL) httpHeaderSetting:(CONTENT_TYPE) contentType {
    
    [self.operationManager.requestSerializer clearAuthorizationHeader];
    
    [self.operationManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    switch(contentType) {
        case APPLICATION_CONTENT_TYPE: {
            [self.operationManager.requestSerializer setValue:@"UTF-8" forHTTPHeaderField:@"Accept-Charset"];
            [self.operationManager.requestSerializer setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
            [self.operationManager.requestSerializer setValue:@"hMF2Y5aZ72Iu3JQpIFCO" forHTTPHeaderField:@"X-Naver-Client-Id"];
            [self.operationManager.requestSerializer setValue:@"sCwfwsskSH" forHTTPHeaderField:@"X-Naver-Client-Secret"];
        }
            break;
        case MULTIPART_CONTENT_TYPE: {
            [self.operationManager.requestSerializer setValue:@"Multipart/form-data;boundary=*****" forHTTPHeaderField:@"Content_Type"];
            [self.operationManager.requestSerializer setValue:@"Multipart/form-data" forHTTPHeaderField:@"ENCTYPE"];
            [self.operationManager.requestSerializer setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
            
        }
            break;
    }
    
    return YES;
}

#pragma mark - operationManager
- (AFHTTPSessionManager *)operationManager
{
    if(!_operationManager)
    {
        _operationManager = [[AFHTTPSessionManager alloc] init];
        [_operationManager.requestSerializer setTimeoutInterval:NETWORK_TIMEOUT];
        
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
//        responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [_operationManager setResponseSerializer:responseSerializer];
        
    }
    return _operationManager;
}

#pragma mark - POST
- (void) POST:(NSDictionary *)params domainURL:(NSMutableString *)domainURL subConnectionName:(NSString *)subConnectionName bErrorException:(BOOL)bErrorException contentType:(CONTENT_TYPE)contentType success:(void(^)(id responseData))success failure:(void (^)(NSError * error, NSString * serverFault))failure {
    if([self networkCondition]) {
        if([self httpHeaderSetting:contentType]) {
            [self.operationManager POST:[domainURL stringByAppendingPathComponent:subConnectionName] parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                NSLog(@"connection manager - progress");
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"connection manager - success = %@", responseObject);
                if(responseObject) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"connection manager - error = %@", error);
                failure(error, nil);
            }];
        }
    } else {
        [self showAlert:@"에러" message:@"네트워크 연결 상태를 확인해주세요."];
    }
}

#pragma mark - GET
- (void) GET:(NSDictionary *)params domainURL:(NSMutableString *)domainURL subConnectionName:(NSString *)subConnectionName contentType:(CONTENT_TYPE)contentType success:(void(^)(id responseData))success failure:(void (^)(NSError * error, NSString * serverFault))failure {
    if([self networkCondition]) {
        if([self httpHeaderSetting:contentType]) {
            [self.operationManager GET:[domainURL stringByAppendingPathComponent:subConnectionName] parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
                NSLog(@"get connection manager - progress");
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (responseObject) {
                    NSString* newStr = [[NSString alloc] initWithData:responseObject
                                                             encoding:NSUTF8StringEncoding];
                    NSLog(@"get connection manager - success string = %@", newStr);
                    NSDictionary *resDic = [NSDictionary dictionaryWithXMLData:responseObject];
                    if (resDic) {
                        success(resDic);
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"get connection manager - error = %@", error);
                failure(error, nil);
            }];
        }
    } else {
        [self showAlert:@"에러" message:@"네트워크 연결 상태를 확인해주세요."];
    }
}

// send Request
- (void) sendRequest:(NSString *)subUrl dataInfo:(NSDictionary *)dataInfo success:(void (^)(id responseData))success failure:(void (^)(NSError * error, NSString * serverFault))failure
{
    NSMutableString * domainURL = [[NSMutableString alloc] initWithString:@"https://openapi.naver.com/"];
    NSString * subConnectionName = subUrl;
    
    [self GET:dataInfo domainURL:domainURL subConnectionName:subConnectionName contentType:APPLICATION_CONTENT_TYPE success:^(id responseData) {
        if (success) {
            success(responseData);
        }
    } failure:^(NSError *error, NSString *serverFault) {
        if (failure) {
            failure(error, serverFault);
        }
    }];
}

// show alert
-(void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:ok];
    
    [SHAREDAPPDELEGATE.navigationController.topViewController presentViewController:alert animated:YES completion:nil];
}

@end
