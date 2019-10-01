//
//  ALTParserUtil.h
//  ALTSDK
//
//  Created by Alienchang on 2019/4/1.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALTEventConst.h"
#import "ALTEventItem.h"
#import "ALTProjectDataSource.h"
NS_ASSUME_NONNULL_BEGIN

@interface ALTParserUtil : NSObject

/**
 根据业务Time格式，返回TimeInterval
 */
+ (NSTimeInterval)timeWithFormatedTimeString:(NSString *)timeString;


/**
 根据业务Time格式，返回TimeInterval，给帧率的调用此方法
 */
+ (NSTimeInterval)timeWithFormatedTimeString:(NSString *)timeString
                                         fps:(int)fps;


/**
 根据表达式和配置文件中的变量返回表达式判断结果

 */
+ (BOOL)judgeWithCondition:(NSString *)condition
         projectDataSource:(ALTProjectDataSource *)projectDataSource;

+ (NSString *)videoUrlWithPath:(NSString *)path dataSource:(ALTProjectDataSource *)projectDataSource;
+ (NSString *)audioUrlWithPath:(NSString *)path dataSource:(ALTProjectDataSource *)projectDataSource;
+ (NSString *)imageUrlWithPath:(NSString *)path dataSource:(ALTProjectDataSource *)projectDataSource;
@end

NS_ASSUME_NONNULL_END
