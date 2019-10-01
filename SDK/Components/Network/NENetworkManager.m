//
//  NENetworkManager.m
//  MeMe
//
//  Created by Chang Liu on 3/19/18.
//  Copyright © 2018 sip. All rights reserved.
//

#import "NENetworkManager.h"
#import <AFNetworking/AFNetworking.h>
/// System
#import <pthread/pthread.h>

@interface NENetworkManager ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, assign) pthread_mutex_t handleLock;
/// 请求容器，注意键值对，为保证线程安全，requestsDict的操作，均在加锁情况下进行。
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NENetworkBaseRequest *> *requestsDict;
@end
@implementation NENetworkManager
+ (NENetworkManager *)shared {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sessionManager = [AFHTTPSessionManager manager];
        self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/x-protobuf",@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil];
        self.requestsDict = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Public
/// 添加一个HTTP请求，并发送
- (void)addHTTPRequest:(NENetworkBaseRequest *)request {
    NSParameterAssert(request != nil);
    
    NSError * __autoreleasing requestSerializationError = nil;
    // 获取当前请求对应的Task
    request.currentRequestTask = [self getURLSessionTask:request error:&requestSerializationError];
    
    // 如序列化失败，直接回调结束。
    if (requestSerializationError) {
        [self requestDidFailWithRequest:request error:requestSerializationError];
        return;
    }
    
    NSAssert(request.currentRequestTask != nil, @"currentRequestTask error");
    
    [request.currentRequestTask resume];
    [self addRequestToRequestsDict:request];
}

#pragma mark 结合调用流程，依次获取相应实例
/// 1)最终获取NSURLSessionTask，通过设置不同请求类型，序列化类型，和请求参数。
- (NSURLSessionTask *)getURLSessionTask:(NENetworkBaseRequest *)request
                                  error:(NSError * _Nullable __autoreleasing *)error {
    // 设置请求类型
    NERequestHttpMethod method = [request requestMethod];
    // 设置请求的Url
    NSString *url = [self buildCurrentRequestUrl:request];
    // 设置请求参数
    id param = request.requestArgument;
    // 获取AFHTTPRequestSerializer的实例
    
    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    // 根据不同的请求，返回对应的NSURLSessionTask，暂时只支持POST和GET
    switch (method) {
        case NERequestHttpMethod_GET:
            return [self dataTaskWithHTTPMethod:@"GET"
                              requestSerializer:requestSerializer
                                      URLString:url
                                     parameters:param
                      constructingBodyWithBlock:nil
                                          error:error];
        case NERequestHttpMethod_POST:
            if (request.formParamater) {
                return [self dataTaskWithHTTPMethod:@"POST"
                                  requestSerializer:requestSerializer
                                          URLString:url
                                         parameters:nil
                          constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                              for (NSString *paramaterKey in request.formParamater.allKeys) {
                                  NSString *value = request.formParamater[paramaterKey];
                                  NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
                                  [formData appendPartWithFormData:data name:paramaterKey];
                              }
                } error:error];
            } else {
                return [self dataTaskWithHTTPMethod:@"POST"
                                  requestSerializer:requestSerializer
                                          URLString:url
                                         parameters:param
                          constructingBodyWithBlock:nil
                                              error:error];
            }
        default:
            return nil;
            break;
    }
}

// 请求失败相应处理。
- (void)requestDidFailWithRequest:(NENetworkBaseRequest *)request error:(NSError *)error {
    request.httpError = error;
    
    // 当前请求重试请求逻辑，目前简单粗暴，后续结合需求和本地换方面可细化。
    if (request.requestRetryCount > 0) {
        request.requestRetryCount--;
        request.totalRequestCount++;
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(request.retryRequestTimeInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf addHTTPRequest:request];
        });
        return;
    }
    
    // 处理回调完成
    dispatch_async(dispatch_get_main_queue(), ^{
        // 当请求失败，Block回调成功之前的，方便统一处理，子类重载实现，目前未实现。
        if (request.failureCompletionBlock) request.failureCompletionBlock(request);
    });
}


/// 2)构造本次请求的URL地址
- (NSString *)buildCurrentRequestUrl:(NENetworkBaseRequest *)request {
    NSParameterAssert(request != nil);
    
    // baseUrl，如不配置，默认使用全局配置的.globalBaseUrl
    NSString *host;
    if (request.host.length > 0) {
        host = [request.host copy];
    } else {
        host = @"https://bank-ap.meme.chat";
    }
    
    // pathUrl
    NSString *pathUrl = [request.pathUrl copy];
    
    // 最终requestUrl
    NSString *requestUrl = @"";
    
    // 如pathUrl存在.host/.scheme，包含HTTP前缀，说明pathurl传入的是一个完整的URL地址。
    NSURL *tempUrl = [NSURL URLWithString:pathUrl];
    if (tempUrl && tempUrl.host && tempUrl.scheme && [pathUrl hasPrefix:@"http"]) {
        // 赋值requestUrl
        requestUrl = [pathUrl copy];
    } else {
        // 拼接requestUrl
        requestUrl = [NSString stringWithFormat:@"%@%@", host, pathUrl?:@""];
    }
    
    // 转义（URL 不能包含 ASCII 字符集）
    requestUrl = [requestUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    return requestUrl;
}

/// 4)构造NSURLSessionTask的私有方法
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                       constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                                           error:(NSError * _Nullable __autoreleasing *)error {
    NSMutableURLRequest *request = nil;
    
    // 根据有无构造请求体的block的情况来获取request
    if (block) {
        // 参考:AFNetWorking中的multipartFormRequestWithMethod方法
        request = [requestSerializer multipartFormRequestWithMethod:method
                                                          URLString:URLString
                                                         parameters:parameters
                                          constructingBodyWithBlock:block
                                                              error:error];
    } else {
        request = [requestSerializer requestWithMethod:method
                                             URLString:URLString
                                            parameters:parameters
                                                 error:error];
    }
    
    // 获得Request以后来获取dataTask，待联调。
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.sessionManager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //统一处理请求结果
        [self handleRequestResult:dataTask responseObject:responseObject error:error];
    }];
    return dataTask;
}

#pragma mark 处理网络请求结果
/// 统一处理请求结果。参数的返回源自AFNetworking的
- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    pthread_mutex_lock(&_handleLock);
    NENetworkBaseRequest *request = self.requestsDict[@(task.taskIdentifier)];
    pthread_mutex_unlock(&_handleLock);
    
    if (!request) {
        NSLog(@"尝试移除一个请求 = %lu", task.taskIdentifier);
        NSAssert(request, @"handleRequestResult error");
        return;
    }
    
    // 序列化错误
    NSError * __autoreleasing serializationError = nil;
    
    // 获取对应回调数据
    request.responseObject = responseObject;
    if ([request.responseObject isKindOfClass:[NSData class]]) {
        NSLog(@"返回类型为NSData");
    }
    
    // 本次请求错误汇总
    NSError *requestError = nil;
    BOOL allLogicSucceed = YES;
    
    if (error) {
        allLogicSucceed = NO;
        requestError = error;
    } else if (serializationError) {
        allLogicSucceed = NO;
        requestError = serializationError;
    }
    
    if (allLogicSucceed) {
        [self requestDidSucceedWithRequest:request];
    } else {
        [self requestDidFailWithRequest:request error:requestError];
    }
    
    // 将本次请求对象，从容器中移除
    [self removeRequestFromRequestsDict:request];
}

/// 添加请求对象到容器。Identifier为key，request为值
- (void)addRequestToRequestsDict:(NENetworkBaseRequest *)request {
    pthread_mutex_lock(&_handleLock);
    self.requestsDict[@(request.currentRequestTask.taskIdentifier)] = request;
    //  NSLog(@"添加一个请求 = %lu", (unsigned long)request.currentRequestTask.taskIdentifier);
    pthread_mutex_unlock(&_handleLock);
}
/// 移除请求对象从容器。Identifier为key，request为值
- (void)removeRequestFromRequestsDict:(NENetworkBaseRequest *)request {
    pthread_mutex_lock(&_handleLock);
    [self.requestsDict removeObjectForKey:@(request.currentRequestTask.taskIdentifier)];
    //   NSLog(@"移除一个请求 = %lu", request.currentRequestTask.taskIdentifier);
    pthread_mutex_unlock(&_handleLock);
}
// 请求成功相应处理。
- (void)requestDidSucceedWithRequest:(NENetworkBaseRequest *)request {
    // 处理回调完成
    dispatch_async(dispatch_get_main_queue(), ^{
        // 当请求成功，Block回调成功之前的，方便统一处理，子类重载实现，目前未实现。
        if (request.successCompletionBlock) request.successCompletionBlock(request);
    });
}
@end
