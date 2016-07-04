//
//  BHNetworkLogger.h
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/1.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHNetworkLogger : NSObject

+ (void)logDebugRequestInfoWithURL:(NSString *)url
                        httpMethod:(NSInteger)httpMethod
                        methodName:(NSString *)methodName
                            params:(NSDictionary *)params reachabilityStatus:(NSInteger)reachabilityStatus;

+ (void)logDebugResponseInfoWithSessionDataTask:(NSURLSessionDataTask *)sessionDataTask
                                 responseObject:(id)response
                                 authentication:(BOOL)authentication
                                          error:(NSError *)error;

+ (void)logCacheInfoWithResponseData:(id)responseData;

@end
