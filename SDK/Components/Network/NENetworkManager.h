//
//  NENetworkManager.h
//  MeMe
//
//  Created by Chang Liu on 3/19/18.
//  Copyright © 2018 sip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NENetworkBaseRequest.h"
#import "NENetworkENUM.h"
@interface NENetworkManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (NENetworkManager *)shared;
- (void)addHTTPRequest:(NENetworkBaseRequest *)request;

@end
