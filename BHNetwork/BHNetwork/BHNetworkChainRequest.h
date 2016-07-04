//
//  BHNetworkChainRequest.h
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/1.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BHNetworkChainRequest;
@class BHNetworkBaseRequest;
@class BHNetworkResponse;
@protocol BHNetworkChainRequestResponseDelegate <NSObject>

@optional

- (__kindof BHNetworkBaseRequest *)networkChainRequest:(BHNetworkChainRequest *)chainRequest nextNetworkRequestByNetworkRequest:(__kindof BHNetworkBaseRequest *)request finishedByResponse:(BHNetworkResponse *)response;

- (void)networkChainRequest:(BHNetworkChainRequest *)chainRequest networkRequest:(__kindof BHNetworkBaseRequest *)request failedByResponse:(BHNetworkResponse *)response;

@end

@protocol  BHNetworkAccessoryProtocol;

@interface BHNetworkChainRequest : NSObject

@property (nonatomic, weak) id<BHNetworkChainRequestResponseDelegate> delegate;

/**
 *  @brief 初始化链式请求，需要配置一个根请求
 *
 *  @param networkRequest 第一个请求
 *
 *  @return 链式请求对象
 */
- (instancetype)initWithRootNetworkRequest:(__kindof BHNetworkBaseRequest *)networkRequest;


/**
 *  @brief 启动链式请求
 */
- (void)startChainRequest;

/**
 *  @brief 停止链式请求，若启用插件，
 */
- (void)stopChainRequest;

/**
 *  @brief 添加实现了BHNetworkAccessoryProtocol的插件对象
 *
 *  @param accessoryDelegate 插件对象
 
 *  @warning 务必在启动请求之前添加插件。
 */
- (void)addNetworkAccessoryObject:(id<BHNetworkAccessoryProtocol>)accessoryDelegate;
@end
