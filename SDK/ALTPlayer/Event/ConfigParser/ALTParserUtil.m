//
//  ALTParserUtil.m
//  ALTSDK
//
//  Created by Alienchang on 2019/4/1.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTParserUtil.h"
#import "ALTVar.h"


@implementation ALTParserUtil
+ (NSTimeInterval)timeWithFormatedTimeString:(NSString *)timeString {
    if (timeString.length < 6) {
        return 0;
    }
    long hours   = [[timeString substringToIndex:1] integerValue] * 3600;
    long minutes = [[timeString substringWithRange:NSMakeRange(3, 2)] integerValue] * 60;
    long seconds = [[timeString substringWithRange:NSMakeRange(6, 2)] integerValue];
    float milliseconds = [[timeString substringWithRange:NSMakeRange(9, 2)] integerValue] / 1000.;
    return hours + minutes + seconds + milliseconds;
}

+ (NSTimeInterval)timeWithFormatedTimeString:(NSString *)timeString
                                         fps:(int)fps {
    if (timeString.length < 8) {
        return 0;
    }
        
    if ([timeString isEqualToString:@"start"] || [timeString isEqualToString:@"0.5"] || [timeString isEqualToString:@"1.5"] || [timeString isEqualToString:@"2"] || [timeString isEqualToString:@"2.5"] || [timeString isEqualToString:@"3"] || !timeString.length) {
        return 0;
    } else {
        long hours   = [[timeString substringToIndex:1] integerValue] * 3600;
        long minutes = [[timeString substringWithRange:NSMakeRange(3, 2)] integerValue] * 60;
        long seconds = [[timeString substringWithRange:NSMakeRange(6, 2)] integerValue];
        if (timeString.length == 8) {
            NSTimeInterval time = hours + minutes + seconds;
            return time;
        } else {
            float frame = [[timeString substringWithRange:NSMakeRange(9, 2)] floatValue];
            float frameTime = (float)frame / fps;
            NSTimeInterval time = hours + minutes + seconds + frameTime;
            return time;
        }
    }
}

+ (BOOL)judgeWithCondition:(NSString *)condition
         projectDataSource:(ALTProjectDataSource *)projectDataSource {
    NSArray *conditionSegments = [condition componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&^|"]];
    NSMutableArray *andOr = [NSMutableArray new];
    for (NSString *tempString in conditionSegments) {
        if ([tempString isEqualToString:@"|"]) {
            [andOr addObject:@"|"];
        } else if ([tempString isEqualToString:@"&"]) {
            [andOr addObject:@"&"];
        }
    }
    
    BOOL res = NO;
    for (int i = 0; i < conditionSegments.count; ++i) {
        NSString *conditionSegment = conditionSegments[i];
        NSString *andOrString = nil;
        if (i > 0) {
            andOrString = andOr[i - 1];
        }
        if (!andOrString) {
            res = [self compareWithConditionSegment:conditionSegment dataSource:projectDataSource];
        } else if ([andOrString isEqualToString:@"|"]) {
            res = res || [self compareWithConditionSegment:conditionSegment dataSource:projectDataSource];
        } else if ([andOrString isEqualToString:@"&"]) {
            res = res && [self compareWithConditionSegment:conditionSegment dataSource:projectDataSource];
        }
    }
    return res;
}

+ (BOOL)compareWithConditionSegment:(NSString *)conditionSegment dataSource:(ALTProjectDataSource *)dataSource {
    if ([conditionSegment containsString:@">="]) {
        NSArray *vars = [conditionSegment componentsSeparatedByString:@">="];
        if (vars.count > 1) {
            NSString *key = vars[0];
            ALTVar *var = dataSource.varsDictionary[key];
            int var2 = [vars[1] intValue];
            if (var.value.intValue >= var2) {
                return YES;
            } else {
                return NO;
            }
        }
    } else if ([conditionSegment containsString:@"<="]) {
        NSArray *vars = [conditionSegment componentsSeparatedByString:@"<="];
        if (vars.count > 1) {
            NSString *key = vars[0];
            ALTVar *var = dataSource.varsDictionary[key];
            int var2 = [vars[1] intValue];
            if (var.value.intValue <= var2) {
                return YES;
            } else {
                return NO;
            }
        }
    } else if ([conditionSegment containsString:@"!="]) {
        NSArray *vars = [conditionSegment componentsSeparatedByString:@"!="];
        if (vars.count > 1) {
            NSString *key = vars[0];
            ALTVar *var = dataSource.varsDictionary[key];
            int var2 = [vars[1] intValue];
            if (var.value.intValue != var2) {
                return YES;
            } else {
                return NO;
            }
        }
    }else if ([conditionSegment containsString:@">"]) {
        NSArray *vars = [conditionSegment componentsSeparatedByString:@">"];
        if (vars.count > 1) {
            NSString *key = vars[0];
            ALTVar *var = dataSource.varsDictionary[key];
            int var2 = [vars[1] intValue];
            if (var.value.intValue > var2) {
                return YES;
            } else {
                return NO;
            }
        }
    } else if ([conditionSegment containsString:@"<"]) {
        NSArray *vars = [conditionSegment componentsSeparatedByString:@"<"];
        if (vars.count > 1) {
            NSString *key = vars[0];
            ALTVar *var = dataSource.varsDictionary[key];
            int var2 = [vars[1] intValue];
            if (var.value.intValue < var2) {
                return YES;
            } else {
                return NO;
            }
        }
    } else if ([conditionSegment containsString:@"="]) {
        NSArray *vars = [conditionSegment componentsSeparatedByString:@"="];
        if (vars.count > 1) {
            NSString *key = vars[0];
            ALTVar *var = dataSource.varsDictionary[key];
            int var2 = [vars[1] intValue];
            if (var.value.intValue == var2) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    return NO;
}

+ (NSString *)videoUrlWithPath:(NSString *)path dataSource:(ALTProjectDataSource *)projectDataSource {
    NSString *videoUrl = [NSString stringWithFormat:@"%@%@",projectDataSource.project.videoBaseUrl,path];
    if (videoUrl) {
        return videoUrl;
    }
    return nil;
}
+ (NSString *)audioUrlWithPath:(NSString *)path dataSource:(ALTProjectDataSource *)projectDataSource {
    return nil;
}
+ (NSString *)imageUrlWithPath:(NSString *)path dataSource:(ALTProjectDataSource *)projectDataSource {
    return nil;
}
@end
