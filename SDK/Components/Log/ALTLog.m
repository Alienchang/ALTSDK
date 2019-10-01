//
//  ALTLog.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/13.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import "ALTLog.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "ALTLogFormatter.h"
@implementation ALTLog
+ (void)setupControlLog:(BOOL)controlLog
               localLog:(BOOL)localLog {
    if (!controlLog && !localLog) {
        return ;
    }
    ALTLogFormatter *logFormatter = [ALTLogFormatter new];
    if (controlLog) {
        [[DDTTYLogger sharedInstance] setLogFormatter:logFormatter];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    }
    if (localLog) {
        [[DDOSLogger sharedInstance] setLogFormatter:logFormatter];
        [DDLog addLogger:[DDOSLogger sharedInstance]];
    }
    DDFileLogger *fileLogger = [DDFileLogger new];
    /// 刷新频率
    [fileLogger setRollingFrequency:60 * 60 * 24];
    [fileLogger.logFileManager setMaximumNumberOfLogFiles:7];
    [DDLog addLogger:fileLogger withLevel:DDLogLevelError];
}

+ (NSArray *)getAllLogFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesPath = [paths objectAtIndex:0];
    NSString *logPath = [cachesPath stringByAppendingPathComponent:@"Logs"];
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *fileArray = [fileManger contentsOfDirectoryAtPath:logPath error:&error];
    NSMutableArray *result = [NSMutableArray array];
    [fileArray enumerateObjectsUsingBlock:^(NSString *filePath, NSUInteger idx, BOOL * _Nonnull stop) {
        if([filePath hasPrefix:[NSBundle mainBundle].bundleIdentifier]){
            NSString *logFilePath = [logPath stringByAppendingPathComponent:filePath];
            [result addObject:logFilePath];
        }
    }];
    return result;
}

+ (NSArray *)getAllLogFileContent {
    NSMutableArray *result = [NSMutableArray array];
    NSArray *logfilePaths = [self getAllLogFilePath];
    [logfilePaths enumerateObjectsUsingBlock:^(NSString *filePath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [result addObject:content];
    }];
    return result;
}

@end
