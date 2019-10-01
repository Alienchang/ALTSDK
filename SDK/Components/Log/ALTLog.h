//
//  ALTLog.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/13.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALTLog : NSObject

/**
 开启log控制

 @param controlLog 控制台输出
 @param localLog 磁盘写入
 */
+ (void)setupControlLog:(BOOL)controlLog
               localLog:(BOOL)localLog;
/**
 获取日志路径(文件名bundleid+空格+日期)
 */
+ (NSArray *)getAllLogFilePath;

/**
 获取日志内容
 */
+ (NSArray *)getAllLogFileContent;
@end

