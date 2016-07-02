//
//  BHNetworkResponseProtocol.h
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/1.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BHNetworkBaseRequest;
@class BHNetworkResponse;

@protocol BHNetworkResponseProtocol <NSObject>

@optional

/**
 *  @brief 请求成功的回调
 *
 *  @param networkRequest 请求对象
 *  @param response       响应的数据（BHNetworkResponse）
 *  @warning 若此请求允许缓存，请在此回调中根据response 的isCache 或 networkStatus 属性 做判断处理
 */
- (void)networkRequest:(__kindof BHNetworkBaseRequest *)networkRequest succeedByResponse:(BHNetworkResponse *)response;

/**
 *  @brief 请求失败的回调
 *
 *  @param networkRequest 请求对象
 *  @param response       响应的数据（BHNetworkResponse）
 */
- (void)networkRequest:(__kindof BHNetworkBaseRequest *)networkRequest failedByResponse:(BHNetworkResponse *)response;

/**
 *  @brief 请求进度的回调，一般适用于上传文件
 *
 *  @param networkRequest 请求对象
 *  @param progress       进度
 */
- (void)networkRequest:(__kindof BHNetworkBaseRequest *)networkRequest requestingByProgress:(NSProgress *)progress;

@end
