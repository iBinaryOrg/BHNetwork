//
//  BHNetworkBatchRequest.h
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/1.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BHNetworkBatchRequest;
@class BHNetworkResponse;
@protocol BHNetworkBatchRequestResponseDelegate <NSObject>

@optional
- (void)networkBatchRequest:(BHNetworkBatchRequest *)batchRequest completedByResponseArray:(NSArray<BHNetworkResponse *> *)responseArray;

@end

@class BHNetworkBaseRequest;
@protocol  BHNetworkAccessoryProtocol;
@interface BHNetworkBatchRequest : NSObject
@property (nonatomic, weak) id<BHNetworkBatchRequestResponseDelegate>delegate;

/**
 *  @brief 当某一个请求错误时，其他请求是否继续，默认YES继续
 */
@property (nonatomic, assign) BOOL isContinueByFailResponse;

- (instancetype)initWithRequestArray:(NSArray<BHNetworkBaseRequest *> *)requestArray;

/**
 *  @brief 开始网络请求
 */
- (void)startBatchRequest;

/**
 *  @brief 停止网络请求
 */
- (void)stopBatchRequest;

/**
 *  @brief 添加实现了BHNetworkAccessoryProtocol的插件对象
 *
 *  @param accessoryDelegate 插件对象
 *  @warning 务必在启动请求之前添加插件。
 */
- (void)addNetworkAccessoryObject:(id<BHNetworkAccessoryProtocol>)accessoryDelegate;
@end
