//
//  BHNetworkChainRequest.m
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/1.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import "BHNetworkChainRequest.h"
#import "BHNetworkBaseRequest.h"
#import "BHNetworkResponseProtocol.h"

@interface BHNetworkChainRequest ()<BHNetworkResponseProtocol>

@property (nonatomic, strong) NSMutableArray *accessoryArray;
@property (nonatomic, strong) BHNetworkBaseRequest *currentNetworkRequest;

@end

@implementation BHNetworkChainRequest

- (instancetype)initWithRootNetworkRequest:(__kindof BHNetworkBaseRequest *)networkRequest {
    self = [super init];
    if (self) {
        _currentNetworkRequest = networkRequest;
    }
    return self;
}

- (void)startChainRequest {
    [self accessoryWillStart];
    _currentNetworkRequest.responseDelegate = self;
    [self.currentNetworkRequest startRequest];
}

- (void)stopChainRequest {
    [self accessoryWillStop];
    [self.currentNetworkRequest stopRequest];
    [self accessoryDidStop];
}

- (void)dealloc {
    [self stopChainRequest];
}


#pragma mark-
#pragma mark-SANetworkResponseProtocol

- (void)networkRequest:(__kindof BHNetworkBaseRequest *)networkRequest succeedByResponse:(BHNetworkResponse *)response {
    if ([self.delegate respondsToSelector:@selector(networkChainRequest:nextNetworkRequestByNetworkRequest:finishedByResponse:)]) {
        BHNetworkBaseRequest *nextRequest = [self.delegate networkChainRequest:self nextNetworkRequestByNetworkRequest:networkRequest finishedByResponse:response];
        if (nextRequest != nil) {
            nextRequest.responseDelegate = self;
            [nextRequest startRequest];
            self.currentNetworkRequest = nextRequest;
            return;
        }
    }
    [self accessoryDidStop];
}

- (void)networkRequest:(__kindof BHNetworkBaseRequest *)networkRequest failedByResponse:(BHNetworkResponse *)response {
    [self accessoryWillStop];
    if ([self.delegate respondsToSelector:@selector(networkChainRequest:networkRequest:failedByResponse:)]) {
        [self.delegate networkChainRequest:self networkRequest:networkRequest failedByResponse:response];
    }
    [self accessoryDidStop];
}

#pragma mark-
#pragma mark-Accessory

- (void)addNetworkAccessoryObject:(id<BHNetworkAccessoryProtocol>)accessoryDelegate {
    if (!_accessoryArray) {
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
