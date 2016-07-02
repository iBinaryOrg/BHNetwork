//
//  BHNetworkBaseRequest.h
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/1.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BHNetworkAccessoryProtocol.h"
#import "BHNetworkInterceptorProtocol.h"
#import "BHNetworkRequestConfigProtocol.h"
#import "BHNetworkRequestParamSourceProtocol.h"
#import "BHNetworkResponseProtocol.h"

@interface BHNetworkBaseRequest : NSObject

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@property (nonatomic, weak, readonly) NSObject<BHNetworkRequestConfigProtocol> *requestConfigProtocol;
@property (nonatomic, weak) id <BHNetworkRequestParamSourceProtocol>requestParamSourceDelegate;

@property (nonatomic, weak) id <BHNetworkResponseProtocol>responseDelegate;
@property (nonatomic, weak) id <BHNetworkInterceptorProtocol>interceptorDelegate;

@property (nonatomic, weak) id <BHNetworkAccessoryProtocol>accessoryDelegate;

/**
 *  @brief 开始网络请求，使用delegate 方式使用这个方法
 */
- (void)startRequest;

/**
 *  @brief 停止网络请求
 */
- (void)stopRequest;

/**
 *  @brief 添加实现了BHNetworkAccessoryProtocol的插件对象
 *
 *  @param accessoryDelegate 插件对象
 *  @warning 务必在启动请求之前添加插件。
 */
- (void)addNetworkAccessoryObject:(id<BHNetworkAccessoryProtocol>)accessoryDelegate;

@end

@interface BHNetworkBaseRequest (Accessory)
- (void)accessoryWillStart;
- (void)accessoryWillStop;
- (void)accessoryDidStop;
@end
