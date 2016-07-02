//
//  BHNetworkConfig.m
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/2.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import "BHNetworkConfig.h"

@implementation BHNetworkConfig

+ (BHNetworkConfig *)sharedInstance {
    static BHNetworkConfig *networkConfigInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkConfigInstance = [[BHNetworkConfig alloc] init];
    });
    return networkConfigInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html", nil];
        _requestSerializerType = BHRequestSerializerTypeHTTP;
        _requestTimeoutInterval = 20.0f;
        _enableDebug = YES;
    }
    return self;
}

@end
