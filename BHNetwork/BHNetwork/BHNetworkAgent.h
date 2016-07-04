//
//  BHNetworkAgent.h
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/1.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BHNetworkBaseRequest;
@protocol BHNetworkRequestConfigProtocol;
@interface BHNetworkAgent : NSObject

+ (BHNetworkAgent *)sharedInstance;

/**
 *  @brief 添加request到请求栈中，并启动
 *
 *  @param request 一个基于BHBaseRequest的实例
 */
- (void)addRequest:(__kindof BHNetworkBaseRequest *)request;

/**
 *  @brief 结束一个请求，并从请求栈中移除
 *
 *  @param request 一个基于BHBaseRequest的实例
 */
- (void)removeRequest:(__kindof BHNetworkBaseRequest *)request;

@end
