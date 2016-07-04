//
//  BHNetworkBaseRequest.m
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/1.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import "BHNetworkBaseRequest.h"
#import "BHNetworkAgent.h"

@interface BHNetworkBaseRequest ()
@property (nonatomic, weak) id <BHNetworkRequestConfigProtocol> requestConfigProtocol;

@property (nonatomic, strong) NSMutableArray *accessoryArray;


@end

@implementation BHNetworkBaseRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(BHNetworkRequestConfigProtocol)]) {
            _requestConfigProtocol = (id <BHNetworkRequestConfigProtocol>)self;
        }else{
            NSAssert(NO, @"子类必须实现BHNetworkConfigProtocol协议");
        }
    }
    return self;
}

- (void)startRequest {
    [self accessoryWillStart];
    [[BHNetworkAgent sharedInstance] addRequest:self];
}


- (void)stopRequest {
    [self accessoryWillStop];
    [[BHNetworkAgent sharedInstance] removeRequest:self];
    [self accessoryDidStop];
}

- (void)dealloc {
    [self stopRequest];
}

#pragma mark-
#pragma mark-Accessory

- (void)addNetworkAccessoryObject:(id<BHNetworkAccessoryProtocol>)accessoryDelegate {
    if (_accessoryArray == nil) {
        _accessoryArray = [NSMutableArray array];
    }
    [self.accessoryArray addObject:accessoryDelegate];
}

- (void)accessoryWillStart {
    for (id<BHNetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryWillStart)]) {
            [accessory networkRequestAccessoryWillStart];
        }
    }
}

- (void)accessoryWillStop {
    for (id<BHNetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryWillStop)]) {
            [accessory networkRequestAccessoryWillStop];
        }
    }
}

- (void)accessoryDidStop {
    for (id<BHNetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidStop)]) {
            [accessory networkRequestAccessoryDidStop];
        }
    }
}

@end
