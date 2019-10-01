//
//  ALTLogFormatter.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/13.
//  Copyright © 2019年 Alienchang. All rights reserved.
//

#import "ALTLogFormatter.h"

@interface ALTLogFormatter()

@end

@implementation ALTLogFormatter
- (NSString * _Nullable)formatLogMessage:(nonnull DDLogMessage *)logMessage {
    NSString *loglevel = nil;
    switch (logMessage.flag){
        case DDLogFlagError:
            loglevel = @"[ERROR]--->";
            break;
        case DDLogFlagWarning:
            loglevel = @"[WARN]--->";
            break;
        case DDLogFlagInfo:
            loglevel = @"[INFO]--->";
            break;
        case DDLogFlagDebug:
            loglevel = @"[DEBUG]--->";
            break;
        case DDLogFlagVerbose:
            loglevel = @"[VBOSE]--->";
            break;
        default:
            break;
    }
    
    NSString *resultString = [NSString stringWithFormat:@"%@ %@___line[%ld]__%@", loglevel, logMessage->_function, logMessage->_line, logMessage->_message];
    return resultString;
}

- (void)logMessage:(nonnull DDLogMessage *)logMessage {
    [super logMessage:logMessage];
}

@end
