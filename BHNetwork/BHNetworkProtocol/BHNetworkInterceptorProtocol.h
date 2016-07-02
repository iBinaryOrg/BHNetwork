//
//  BHNetworkInterceptorProtocol.h
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/1.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BHNetworkBaseRequest;
@class BHNetworkResponse;

@protocol BHNetworkInterceptorProtocol <NSObject>

@optional

- (void)networkRequest:(__kindof BHNetworkBaseRequest *)networkRequest beforePerformSuccessWithResponse:(BHNetworkResponse *)networkResponse;

- (void)networkRequest:(__kindof BHNetworkBaseRequest *)networkRequest afterPerformSuccessWithResponse:(BHNetworkResponse *)networkResponse;

- (void)networkRequest:(__kindof BHNetworkBaseRequest *)networkRequest beforePerformFailWithResponse:(BHNetworkResponse *)networkResponse;

- (void)networkRequest:(__kindof BHNetworkBaseRequest *)networkRequest afterPerformFailWithResponse:(BHNetworkResponse *)networkResponse;

@end
