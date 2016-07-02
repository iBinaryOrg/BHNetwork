//
//  BHNetworkAccessoryProtocol.h
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/1.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @brief 请求插件协议
 */
@protocol BHNetworkAccessoryProtocol <NSObject>

@optional

/**
 *  @brief 请求将要执行
 */
- (void)networkRequestAccessoryWillStart;

/**
 *  @brief 请求将要停止
 */
- (void)networkRequestAccessoryWillStop;

/**
 *  @brief 请求已经得到响应
 */
- (void)networkRequestAccessoryDidStop;

@end
