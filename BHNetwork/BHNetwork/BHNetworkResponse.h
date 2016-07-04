//
//  BHNetworkResponse.h
//  BHNetworkDemo
//
//  Created by 阿宝 on 16/7/1.
//  Copyright © 2016年 iBinaryOrg. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @brief 网络请求状态值
 */
typedef NS_ENUM(NSInteger, BHNetworkStatus) {
    /**
     *  @brief 网络不可达
     */
    BHNetworkNotReachableStatus,
    /**
     *  @brief 请求参数错误
     */
    BHNetworkRequestParamIncorrectStatus,
    /**
     *  @brief 请求失败
     */
    BHNetworkResponseFailureStatus,
    /**
     *  @brief 允许缓存的接口，取到缓存数据
     */
    BHNetworkResponseDataCacheStatus,
    /**
     *  @brief 请求返回的数据错误，可能是接口错误等等
     */
    BHNetworkResponseDataIncorrectStatus,
    /**
     *  @brief 请求返回的数据没有通过验证
     */
    BHNetworkResponseDataAuthenticationFailStatus,
    /**
     *  @brief 数据请求成功
     */
    BHNetworkResponseDataSuccessStatus,
};

@protocol BHNetworkResponseReformerProtocol;
@interface BHNetworkResponse : NSObject

/**
 *  请求得到的全部数据
 */
@property (nonatomic, copy, readonly) id responseData;
@property (nonatomic, assign, readonly) BHNetworkStatus networkStatus;
@property (nonatomic, assign, readonly) NSInteger requestTag;
@property (nonatomic, assign, readonly) BOOL isCache;

- (instancetype)initWithResponseData:(id)responseData
                          requestTag:(NSInteger)requestTag
                       networkStatus:(BHNetworkStatus)networkStatus;

- (id)fetchDataWithReformer:(id<BHNetworkResponseReformerProtocol>)reformer;

/***  以下属性取决于你服务端返回的数据格式，以及BHNetworkConfig是否设定了对应属性值的key值***/

@property (nonatomic, copy, readonly) id responseContentData;
@property (nonatomic, copy, readonly) NSString *responseMessage; //请求无网、失败、参数错误、验证失败的情况，此属性都有值
@property (nonatomic, assign, readonly) NSInteger responseCode;
@end

@protocol BHNetworkResponseReformerProtocol <NSObject>

@required

/**
 *  @brief 将数据进行一定的改造，方便在业务层统一处理
 
 *  @see 引“RTNetworking”的注解：
 比如同样的一个获取电话号码的逻辑，二手房，新房，租房调用的API不同，所以它们的manager和data都会不同。
 即便如此，同一类业务逻辑（都是获取电话号码）还是应该写到一个reformer里面去的。这样后人定位业务逻辑相关代码的时候就非常方便了。
 
 代码样例：
 - (id)networkResponse:(SANetworkResponse *)networkResponse reformerDataWithOriginData:(id)originData
 {
 if (networkResponse.requestTag == xinfangManager.tag]) {
 return [self xinfangPhoneNumberWithData:data];      //这是调用了派生后reformer子类自己实现的函数，别忘了reformer自己也是一个对象呀。
 //reformer也可以有自己的属性，当进行业务逻辑需要一些外部的辅助数据的时候，
 //外部使用者可以在使用reformer之前给reformer设置好属性，使得进行业务逻辑时，
 //reformer能够用得上必需的辅助数据。
 }
 
 if (networkResponse.requestTag == zufangManager.tag) {
 return [self zufangPhoneNumberWithData:data];
 }
 
 if (networkResponse.requestTag == ershoufangManager.tag) {
 return [self ershoufangPhoneNumberWithData:data];
 }
 }
 
 *
 *  @param networkResponse 响应数据对象（BHNetworkResponse）
 *  @param originData     响应的源数据
 *
 *  @return 改革后的数据
 */
- (id)networkResponse:(BHNetworkResponse *)networkResponse reformerDataWithOriginData:(id)originData;

@end
