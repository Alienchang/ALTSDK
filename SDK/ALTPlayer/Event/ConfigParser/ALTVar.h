//
//  ALTVar.h
//  ALTSDK
//
//  Created by Alienchang on 2019/4/3.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALTVar : NSObject
@property (nonatomic ,copy) NSString *varId;
@property (nonatomic ,copy) NSString *type;
@property (nonatomic ,copy) NSString *value;
@end

NS_ASSUME_NONNULL_END
