//
//  NENetworkNUM.h
//  NESocialClient
//
//  Created by Alienchang on 2017/10/18.
//  Copyright © 2017年 Alienchang. All rights reserved.
//

/*
 * 所有组件内枚举，最终都会映射到AFNetworkging中。我们只是做了接口层面的封装。
 */

/// AF全支持的，但咱们项目中暂时只用2种，需要再扩展下。
typedef NS_ENUM(NSInteger, NERequestHttpMethod) {
    NERequestHttpMethod_POST = 0,
    NERequestHttpMethod_GET = 1,
};

/// 映射AFHTTPResquestSerializer，"HTTP"/"JSON"/Request，需要再扩展下。
typedef NS_ENUM(NSInteger, NERequestSerializerType) {
    NERequestSerializerType_HTTP = 0,
    NERequestSerializerType_JSON = 1,
    NERequestSerializerType_Protobuf = 2,
};

/// 映射AFHTTPResponseSerializer，"JSON"/"XMLParser"/Response，需要再扩展下。均基于AFHTTPResponseSerializer
typedef NS_ENUM(NSInteger, NEResponseSerializerType) {
    NEResponseSerializerType_HTTP = 0,
    NEResponseSerializerType_JSON = 1,
    NEResponseSerializerType_XML = 2,
    NEResponseSerializerType_Protobuf = 3,
};

/// 映射到NSURLSessionTask的Priority
typedef NS_ENUM(NSInteger, NERequestPriority) {
    NERequestPriorityLow = -1,
    NERequestPriorityDefault = 0,
    NERequestPriorityHigh = 1,
};

/// 映射到NEReachabilityStatus
typedef NS_ENUM(NSInteger, NEReachabilityStatus) {
    NEReachabilityStatusUnknown = -1,
    NEReachabilityStatusNotReachable = 0,
    NEReachabilityStatusReachableViaWWAN = 1,
    NEReachabilityStatusReachableViaWiFi = 2,
};
