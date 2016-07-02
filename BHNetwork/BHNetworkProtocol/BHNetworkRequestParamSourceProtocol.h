//
//  BHNetworkRequestParamSourceProtocol.h
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/1.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BHNetworkRequestParamSourceProtocol <NSObject>

@required
/**
 *  @brief 请求所需要的参数
 *
 *  @return 参数字典
 */

- (NSDictionary *)requestParamDictionary;

@end
