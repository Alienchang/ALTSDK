//
//  NENetworkBaseRequest.h
//  MeMe
//
//  Created by Chang Liu on 3/19/18.
//  Copyright © 2018 sip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NENetworkENUM.h"
@interface NENetworkBaseRequest : NSObject
typedef void(^NERequestCompletionBlock)(__kindof NENetworkBaseRequest *request);
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *pathUrl;
/// 请求成功，主线程回掉。
@property (nonatomic, copy) NERequestCompletionBlock successCompletionBlock;
/// 请求失败，主线程回掉。
@property (nonatomic, copy) NERequestCompletionBlock failureCompletionBlock;
/// 配置请求头添加参数。默认：nil
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *requestHeaderFieldValueDictionary;
/// 当前请求的Task，"addRequest"中被幅值
@property (nonatomic, strong) NSURLSessionTask *currentRequestTask;
/// 当前请求的Error，"requestDidFailWithRequest"中被赋值
@property (nonatomic, strong) NSError *httpError;
/// 配置请求方式。默认：POST
@property (nonatomic, assign) NERequestHttpMethod requestMethod;
/// 配置请求的参数列表、请求的参数，因兼容PB，所以传值类型会多变
@property (nonatomic, strong) id requestArgument;
/// 当前请求回调，id格式，"可能被赋值为json,xml,data等格式"。
@property (nonatomic, strong) id responseObject;
/// 配置重试次数，默认：0=不重试，最大重试次数，3次。如设置3，加上本身的请求，共4次，可通过回掉中的"totalRequestCount"确认。
@property (nonatomic, assign) NSUInteger requestRetryCount;
/// 配置重试间隔时间，默认：2秒，最大间隔6秒。会在系统默认子线程中重试。目前较为简单粗暴，后续结合需求在考虑细化重试方案。
@property (nonatomic, assign) NSUInteger retryRequestTimeInterval;
/// 当前请求累计请求次数。默认= 1
@property (nonatomic, assign) NSUInteger totalRequestCount;
/// 表单数据
@property (nonatomic ,strong) NSDictionary *formParamater;
@end
