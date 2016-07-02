//
//  BHNetworkBatchRequest.m
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/1.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import "BHNetworkBatchRequest.h"
#import "BHNetworkResponseProtocol.h"
#import "BHNetworkBaseRequest.h"

@interface BHNetworkBatchRequest ()<BHNetworkResponseProtocol>

@property (nonatomic) NSInteger completedCount;
@property (nonatomic, strong) NSArray<BHNetworkBaseRequest *> *requestArray;
@property (nonatomic, strong) NSMutableArray *accessoryArray;
@property (nonatomic, strong) NSMutableArray<BHNetworkResponse *> *responseArray;

@end

@implementation BHNetworkBatchRequest

- (instancetype)initWithRequestArray:(NSArray<BHNetworkBaseRequest *> *)requestArray {
    self = [super init];
    if (self) {
        _requestArray = requestArray;
        _responseArray = [NSMutableArray array];
        _completedCount = 0;
        _isContinueByFailResponse = YES;
    }
    return self;
}
- (void)startBatchRequest {
    if (self.completedCount > 0 ) {
        NSLog(@"批量请求正在进行，请勿重复启动  !");
        return;
    }
    
    [self accessoryWillStart];
    for (BHNetworkBaseRequest *networkRequest in self.requestArray) {
        networkRequest.responseDelegate = self;
        [networkRequest startRequest];
    }
}

- (void)stopBatchRequest {
    [self accessoryWillStop];
    _delegate = nil;
    for (BHNetworkBaseRequest *networkRequest in self.requestArray) {
        [networkRequest stopRequest];
    }
    [self accessoryDidStop];
}



#pragma mark-
#pragma mark-SANetworkResponseProtocol

- (void)networkRequest:(BHNetworkBaseRequest *)networkRequest succeedByResponse:(BHNetworkResponse *)response{
    self.completedCount++;
    [self.responseArray addObject:response];
    if (self.completedCount == self.requestArray.count) {
        [self accessoryWillStop];
        [self networkBatchRequestCompleted];
    }
}

- (void)networkRequest:(BHNetworkBaseRequest *)networkRequest failedByResponse:(BHNetworkResponse *)response {
    [self.responseArray addObject:response];
    
    if (self.isContinueByFailResponse) {
        self.completedCount++;
        if (self.completedCount == self.requestArray.count) {
            [self accessoryWillStop];
            [self networkBatchRequestCompleted];
        }
    }else{
        [self accessoryWillStop];
        for (BHNetworkBaseRequest *networkRequest in self.requestArray) {
            [networkRequest stopRequest];
        }
        [self networkBatchRequestCompleted];
    }
}



- (void)networkBatchRequestCompleted{
    if ([self.delegate respondsToSelector:@selector(networkBatchRequest:completedByResponseArray:)]) {
        [self.delegate networkBatchRequest:self completedByResponseArray:self.responseArray];
    }
    [self accessoryDidStop];
    self.completedCount = 0;
}

- (void)dealloc {
    [self stopBatchRequest];
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
