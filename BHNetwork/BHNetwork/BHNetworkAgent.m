//
//  BHNetworkAgent.m
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/1.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import "BHNetworkAgent.h"
#import <CommonCrypto/CommonDigest.h>
#import <AFNetworking/AFNetworking.h>
#import <PINCache/PINCache.h>

#import "BHNetworkConfig.h"
#import "BHNetworkBaseRequest.h"
#import "BHNetworkResponse.h"
#import "BHNetworkLogger.h"

@interface BHNetworkAgent ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableDictionary <NSString*, __kindof BHNetworkBaseRequest*>*requestRecordDict;

@end

@implementation BHNetworkAgent

+ (BHNetworkAgent *)sharedInstance {
    static BHNetworkAgent *networkAgentInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkAgentInstance = [[self alloc] init];
    });
    return networkAgentInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestRecordDict = [NSMutableDictionary dictionary];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return self;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        _sessionManager.operationQueue.maxConcurrentOperationCount = 3;
        _sessionManager.responseSerializer.acceptableContentTypes = [BHNetworkConfig sharedInstance].acceptableContentTypes;
    }
    return _sessionManager;
}

#pragma mark-
#pragma mark-Getter

- (NSString *)urlStringByRequest:(__kindof BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *)request {
    NSString *detailUrl = @"";
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestMethodName)]) {
        detailUrl = [request.requestConfigProtocol requestMethodName];
    }
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    NSString *baseUrlString = nil;
    if ([request.requestConfigProtocol respondsToSelector:@selector(useViceURL)] && [request.requestConfigProtocol useViceURL]) {
        baseUrlString = [BHNetworkConfig sharedInstance].viceBaseUrlString;
    }else{
        baseUrlString = [BHNetworkConfig sharedInstance].mainBaseUrlString;
    }
    if (baseUrlString) {
        return [baseUrlString stringByAppendingPathComponent:detailUrl];
    }
    NSLog(@"\n\n\n请设置请求的URL\n\n\n");
    return nil;
}

- (NSDictionary *)requestParamByRequest:(__kindof BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *)request {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    if (request.requestParamSourceDelegate) {
        NSDictionary *paramDict = [request.requestParamSourceDelegate requestParamDictionary];
        if (paramDict != nil) {
            [tempDict addEntriesFromDictionary:paramDict];
        }
    }
    
    if ([BHNetworkConfig sharedInstance].baseParamSourceBlock && [request.requestConfigProtocol respondsToSelector:@selector(useBaseRequestParamSource)] && [request.requestConfigProtocol useBaseRequestParamSource] ) {
        NSDictionary *baseRequestParamSource = [BHNetworkConfig sharedInstance].baseParamSourceBlock();
        if (baseRequestParamSource != nil) {
            [tempDict addEntriesFromDictionary:baseRequestParamSource];
        }
    }
    if (tempDict.count == 0) {
        return nil;
    }
    return [NSDictionary dictionaryWithDictionary:tempDict];
}

- (BOOL)isCorrectByRequestParams:(NSDictionary *)requestParams request:(__kindof BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(isCorrectWithRequestParams:)]) {
        return [request.requestConfigProtocol isCorrectWithRequestParams:requestParams];
    }
    return YES;
}

- (BOOL)shouldCancelPreviousRequestByRequest:(__kindof BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(shouldCancelPreviousRequest)]) {
        return [request.requestConfigProtocol shouldCancelPreviousRequest];
    }
    return NO;
}

- (BHRequestMethod)requestMethodByRequest:(__kindof BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestMethod)]) {
        return [request.requestConfigProtocol requestMethod];
    }
    return BHRequestMethodPost;
}

- (BOOL)shouldCacheDataByRequest:(__kindof BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(shouldCacheResponse)]) {
        return [request.requestConfigProtocol shouldCacheResponse];
    }
    return NO;
}

- (NSString *)keyWithURLString:(NSString *)urlString requestParam:(NSDictionary *)requestParam {
    NSString *cacheKey = [self urlStringWithOriginUrlString:urlString appendParameters:requestParam];
    return [self stringByMd5String:cacheKey];
}

- (void)setupSessionManagerRequestSerializerByRequest:(__kindof BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *)request {
    //配置requestSerializerType
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestSerializerType)]) {
        self.sessionManager.requestSerializer = [request.requestConfigProtocol requestSerializerType] == BHRequestSerializerTypeHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
    }else{
        self.sessionManager.requestSerializer = [BHNetworkConfig sharedInstance].requestSerializerType == BHRequestSerializerTypeHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
    }
    
    //配置请求头
    if ((![request.requestConfigProtocol respondsToSelector:@selector(useBaseHTTPRequestHeaders)] || [request.requestConfigProtocol useBaseHTTPRequestHeaders]) && [BHNetworkConfig sharedInstance].baseHTTPRequestHeadersBlock) {
        NSDictionary *requestHeaders = [BHNetworkConfig sharedInstance].baseHTTPRequestHeadersBlock();
        [requestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    if ([request.requestConfigProtocol respondsToSelector:@selector(customHTTPRequestHeaders)]) {
        NSDictionary *customRequestHeaders = [request.requestConfigProtocol customHTTPRequestHeaders];
        [customRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    //配置请求超时时间
    NSTimeInterval timeoutInterval = [BHNetworkConfig sharedInstance].requestTimeoutInterval;
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestTimeoutInterval)]) {
        timeoutInterval = [request.requestConfigProtocol requestTimeoutInterval];
    }
    self.sessionManager.requestSerializer.timeoutInterval = timeoutInterval;
}

- (AFConstructingBlock)constructingBlockByRequest:(__kindof BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(constructingBodyBlock)]) {
        return [request.requestConfigProtocol constructingBodyBlock];
    }
    return nil;
}
#pragma mark-
#pragma mark-处理Request

- (void)addRequest:(__kindof BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *)request {
    NSString *requestURLString = [self urlStringByRequest:request];
    if ([requestURLString hasPrefix:@"https"]) {
        AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
        [securityPolicy setAllowInvalidCertificates:YES];
        self.sessionManager.securityPolicy = securityPolicy;
    }
    
    NSDictionary *requestParam = [self requestParamByRequest:request];
    //检查参数配置
    if (![self isCorrectByRequestParams:requestParam request:request]) {
        NSLog(@"参数配置有误！请查看isCorrectWithRequestParams: !");
        BHNetworkResponse *paramIncorrectResponse = [[BHNetworkResponse alloc] initWithResponseData:nil requestTag:request.tag networkStatus:BHNetworkRequestParamIncorrectStatus];
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
            [request.responseDelegate networkRequest:request failedByResponse:paramIncorrectResponse];
        }
        [request accessoryDidStop];
        return;
    }
    
    //检查是否存在相同请求方法未完成，并根据协议接口决定是否结束之前的请求
    BOOL isContinuePerform = YES;
    for (BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *requestingObj in self.requestRecordDict.allValues) {
        if ([[self urlStringByRequest:requestingObj] isEqualToString:requestURLString]) {
            if ([self shouldCancelPreviousRequestByRequest:request]) {
                [requestingObj accessoryWillStart];
                [self removeRequest:requestingObj];
                [requestingObj accessoryDidStop];
            }else{
                isContinuePerform = NO;
            }
            break;
        }
    }
    
    if (isContinuePerform == NO){
        NSLog(@"有个请求未完成，这个请求被取消了（可设置shouldCancelPreviousRequest）");
        [request accessoryDidStop];
        return;
    }
    
    if ([BHNetworkConfig sharedInstance].enableDebug) {
        [BHNetworkLogger logDebugRequestInfoWithURL:requestURLString httpMethod:[self requestMethodByRequest:request] methodName:[request.requestConfigProtocol requestMethodName] params:requestParam reachabilityStatus:[[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus]];
    }
    
    //检测请求是否缓存数据，并执行缓存数据回调方法
    if ([self shouldCacheDataByRequest:request]) {
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:succeedByResponse:)]) {
            [[PINDiskCache sharedCache] objectForKey:[self keyWithURLString:requestURLString requestParam:requestParam] block:^(PINDiskCache * _Nonnull cache, NSString * _Nonnull key, id<NSCoding>  _Nullable object, NSURL * _Nullable fileURL) {
                if (object) {
                    BHNetworkResponse *cacheResponse = [[BHNetworkResponse alloc] initWithResponseData:object requestTag:request.tag networkStatus:BHNetworkResponseDataCacheStatus];
                    [request.responseDelegate networkRequest:request succeedByResponse:cacheResponse];
                }
                if ([BHNetworkConfig sharedInstance].enableDebug) {
                    [BHNetworkLogger logCacheInfoWithResponseData:object];
                }
            }];
        }
    }
    
    
    if (![AFNetworkReachabilityManager sharedManager].isReachable) {
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
            BHNetworkResponse *notReachableResponse = [[BHNetworkResponse alloc] initWithResponseData:nil requestTag:request.tag networkStatus:BHNetworkNotReachableStatus];
            [request.responseDelegate networkRequest:request failedByResponse:notReachableResponse];
        }
        [request accessoryDidStop];
        return;
    }

    [self setupSessionManagerRequestSerializerByRequest:request];
    __block BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *blockRequest = request;
    switch ([self requestMethodByRequest:request]) {
        case BHRequestMethodGet:{
            request.sessionDataTask = [self.sessionManager GET:requestURLString
                                                    parameters:requestParam
                                                      progress:^(NSProgress * _Nonnull downloadProgress) {
                                                          [self handleRequestProgress:downloadProgress request:blockRequest];
                                                      }
                                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                           [self handleRequestSuccess:task responseObject:responseObject];
                                                       }
                                                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                           [self handleRequestFailure:task error:error];
                                                       }];
        }
            break;
        case BHRequestMethodPost:{
            AFConstructingBlock constructingBlock = [self constructingBlockByRequest:request];
            if (constructingBlock) {
                request.sessionDataTask = [self.sessionManager POST:requestURLString
                                                         parameters:requestParam
                                          constructingBodyWithBlock:constructingBlock
                                                           progress:^(NSProgress * _Nonnull uploadProgress) {
                                                               [self handleRequestProgress:uploadProgress request:blockRequest];
                                                           }
                                                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                                [self handleRequestSuccess:task responseObject:responseObject];
                                                            }
                                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                                [self handleRequestFailure:task error:error];
                                                            }];
            }else{
                request.sessionDataTask = [self.sessionManager POST:requestURLString
                                                         parameters:requestParam
                                                           progress:^(NSProgress * _Nonnull uploadProgress) {
                                                               [self handleRequestProgress:uploadProgress request:blockRequest];
                                                           }
                                                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                                [self handleRequestSuccess:task responseObject:responseObject];
                                                            }
                                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                                [self handleRequestFailure:task error:error];
                                                            }];
            }
        }
            break;
        default:
            break;
    }
    [self addRequestObject:request];

}

- (void)removeRequest:(__kindof BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *)request {
    [request.sessionDataTask cancel];
    [self removeRequestObject:request];
}

#pragma mark-
#pragma mark-处理请求响应结果

- (void)beforePerformFailWithResponse:(BHNetworkResponse *)response request:(BHNetworkBaseRequest *)request{
    if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:beforePerformFailWithResponse:)]) {
        [request.interceptorDelegate networkRequest:request beforePerformFailWithResponse:response];
    }
}
- (void)afterPerformFailWithResponse:(BHNetworkResponse *)response request:(BHNetworkBaseRequest *)request{
    if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:afterPerformFailWithResponse:)]) {
        [request.interceptorDelegate networkRequest:request afterPerformFailWithResponse:response];
    }
}

- (void)handleRequestProgress:(NSProgress *)progress request:(__kindof BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *)request {
    if ([request.responseDelegate respondsToSelector:@selector(networkRequest:requestingByProgress:)]) {
        [request.responseDelegate networkRequest:request requestingByProgress:progress];
    }
}

- (void)handleRequestSuccess:(NSURLSessionDataTask *)sessionDataTask responseObject:(id)response {
    NSString *taskKey = [self keyForSessionDataTask:sessionDataTask];
    BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *request = _requestRecordDict[taskKey];
    [request accessoryWillStop];
    if (request == nil){
        NSLog(@"请求实例被意外释放!");
        [request accessoryDidStop];
        return;
    }
    [self removeRequestObject:request];
    
    BOOL isAuthentication = YES;
    if ([BHNetworkConfig sharedInstance].baseAuthenticationBlock) {
        isAuthentication = [BHNetworkConfig sharedInstance].baseAuthenticationBlock(request,response);
    }
    if(isAuthentication && [request.requestConfigProtocol isCorrectWithResponseData:response]){
        if ([self shouldCacheDataByRequest:request]) {
            [[PINDiskCache sharedCache] setObject:response forKey:[self keyWithURLString:[self urlStringByRequest:request] requestParam:[self requestParamByRequest:request]]];
        }
        
        BHNetworkResponse *successResponse = [[BHNetworkResponse alloc] initWithResponseData:response requestTag:request.tag networkStatus:BHNetworkResponseDataSuccessStatus];
        if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:beforePerformSuccessWithResponse:)]) {
            [request.interceptorDelegate networkRequest:request beforePerformSuccessWithResponse:response];
        }
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:succeedByResponse:)]) {
            [request.responseDelegate networkRequest:request succeedByResponse:successResponse];
        }
        if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:afterPerformSuccessWithResponse:)]) {
            [request.interceptorDelegate networkRequest:request afterPerformSuccessWithResponse:response];
        }
    } else {
        BHNetworkResponse *dataErrorResponse = [[BHNetworkResponse alloc] initWithResponseData:response requestTag:request.tag networkStatus:isAuthentication ? BHNetworkResponseDataIncorrectStatus : BHNetworkResponseDataAuthenticationFailStatus];
        [self beforePerformFailWithResponse:dataErrorResponse request:request];
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
            [request.responseDelegate networkRequest:request failedByResponse:dataErrorResponse];
        }
        [self afterPerformFailWithResponse:dataErrorResponse request:request];
    }
    [request accessoryDidStop];
    if ([BHNetworkConfig sharedInstance].enableDebug) {
        [BHNetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask responseObject:response authentication:isAuthentication error:nil];
    }
}

- (void)handleRequestFailure:(NSURLSessionDataTask *)sessionDataTask error:(NSError *)error {
    NSString *taskKey = [self keyForSessionDataTask:sessionDataTask];
    BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *request = _requestRecordDict[taskKey];
    [request accessoryWillStop];
    [self removeRequestObject:request];
    if (request == nil) {
        NSLog(@"请求实例被意外释放!");
        [request accessoryDidStop];
        return;
    }
    
    BHNetworkResponse *failureResponse = [[BHNetworkResponse alloc] initWithResponseData:nil requestTag:request.tag networkStatus:BHNetworkResponseFailureStatus];
    [self beforePerformFailWithResponse:failureResponse request:request];
    if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
        [request.responseDelegate networkRequest:request failedByResponse:failureResponse];
    }
    [self afterPerformFailWithResponse:failureResponse request:request];
    [request accessoryDidStop];
    if ([BHNetworkConfig sharedInstance].enableDebug) {
        [BHNetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask responseObject:nil authentication:NO error:error];
    }
}

#pragma mark-
#pragma mark-处理 请求集合
- (NSString *)keyForSessionDataTask:(NSURLSessionDataTask *)sessionDataTask {
    return [@(sessionDataTask.taskIdentifier) stringValue];
}

- (void)addRequestObject:(__kindof BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *)request {
    if (request.sessionDataTask == nil)    return;
    
    NSString *taskKey = [self keyForSessionDataTask:request.sessionDataTask];
    @synchronized(self) {
        _requestRecordDict[taskKey] = request;
    }
}

- (void)removeRequestObject:(__kindof BHNetworkBaseRequest<BHNetworkRequestConfigProtocol> *)request {
    if(request.sessionDataTask == nil)  return;
    
    NSString *taskKey = [self keyForSessionDataTask:request.sessionDataTask];
    @synchronized(self) {
        [_requestRecordDict removeObjectForKey:taskKey];
    }
}

#pragma mark-
#pragma mark-Other

- (NSString *)urlStringWithOriginUrlString:(NSString *)originUrlString appendParameters:(NSDictionary *)parameters {
    NSString *filteredUrl = originUrlString;
    NSMutableString *urlParametersString = [[NSMutableString alloc] initWithString:@""];
    if (parameters && parameters.count > 0) {
        for (NSString *key in parameters) {
            NSString *value = parameters[key];
            value = [NSString stringWithFormat:@"%@",value];
            value = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)value, CFSTR("."), CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);;
            [urlParametersString appendFormat:@"&%@=%@", key, value];
        }
    }
    if (urlParametersString.length > 0) {
        if ([originUrlString rangeOfString:@"?"].location != NSNotFound) {
            filteredUrl = [filteredUrl stringByAppendingString:urlParametersString];
        } else {
            filteredUrl = [filteredUrl stringByAppendingFormat:@"?%@", [urlParametersString substringFromIndex:1]];
        }
        return filteredUrl;
    } else {
        return originUrlString;
    }
}

- (NSString *)stringByMd5String:(NSString *)string {
    if(string == nil || [string length] == 0)
        return nil;
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}
@end
