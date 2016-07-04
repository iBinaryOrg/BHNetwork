//
//  BHNetworkResponse.m
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/1.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import "BHNetworkResponse.h"
#import "BHNetworkConfig.h"

@interface BHNetworkResponse ()

@property (nonatomic, copy) id responseData;
@property (nonatomic, assign, readwrite) BHNetworkStatus networkStatus;
@property (nonatomic, assign, readwrite) NSInteger requestTag;
@property (nonatomic, assign, readwrite) BOOL isCache;

@property (nonatomic, copy, readwrite) id responseContentData;
@property (nonatomic, copy, readwrite) NSString *responseMessage;
@property (nonatomic, assign, readwrite) NSInteger responseCode;


@end
@implementation BHNetworkResponse

- (instancetype)initWithResponseData:(id)responseData requestTag:(NSInteger)requestTag networkStatus:(BHNetworkStatus)networkStatus {
    self = [super init];
    if (self) {
        _responseData = responseData;
        _requestTag = requestTag;
        _isCache = networkStatus == BHNetworkResponseDataCacheStatus ? YES:NO;
        _networkStatus = networkStatus;
        

        _responseCode = NSNotFound;
        switch (networkStatus) {
            case BHNetworkNotReachableStatus:
                _responseMessage = @"暂无网络连接";
                break;
            case BHNetworkResponseDataSuccessStatus:
            case BHNetworkResponseDataCacheStatus:
            case BHNetworkResponseDataIncorrectStatus:{
                if ([responseData isKindOfClass:[NSDictionary class]]) {
                    if ([BHNetworkConfig sharedInstance].responseCodeKey && responseData[[BHNetworkConfig sharedInstance].responseCodeKey]) {
                        _responseCode = [responseData[[BHNetworkConfig sharedInstance].responseCodeKey] integerValue];
                    }
                    if ([BHNetworkConfig sharedInstance].responseMessageKey) {
                        _responseMessage = responseData[[BHNetworkConfig sharedInstance].responseMessageKey];
                    }
                    if ([BHNetworkConfig sharedInstance].responseContentDataKey) {
                        _responseContentData = responseData[[BHNetworkConfig sharedInstance].responseContentDataKey];
                    }
                }
            }
                break;
            case BHNetworkResponseDataAuthenticationFailStatus:
                _responseMessage = @"数据验证失败";
                break;
            case BHNetworkRequestParamIncorrectStatus:
                _responseMessage = @"请求参数有误";
                break;
            default:
                _responseMessage = @"请求数据失败";
                break;
        }
        

    }
    return self;
}

- (id)fetchDataWithReformer:(id<BHNetworkResponseReformerProtocol>)reformer {
    if ([reformer respondsToSelector:@selector(networkResponse:reformerDataWithOriginData:)]) {
        return [reformer networkResponse:self reformerDataWithOriginData:self.responseData];
    }
    return [self.responseData mutableCopy];
}
@end
