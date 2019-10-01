//
//  ALTProjectDataSource.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/29.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALTEventItem.h"
#import "ALTVideoEvent.h"
#import "ALTProject.h"
#import "ALTVideoResource.h"
NS_ASSUME_NONNULL_BEGIN

@interface ALTProjectDataSource : NSObject
@property (nonatomic ,copy)    NSString *videoUrl;
@property (nonatomic ,assign)  int fps;
/// 项目基本信息
@property (nonatomic ,strong) ALTProject *project;
/// 触发视频事件合集 ，ALTVideoEvent，每个事件组是按时间递增排序
@property (nonatomic ,strong)   NSMutableDictionary *videosDictionary;
/// 事件合集 ，ALTEventItem，事件具体信息
@property (nonatomic ,strong)   NSMutableDictionary *eventsDictionary;
/// 变量合集
@property (nonatomic ,strong)   NSMutableDictionary *varsDictionary;
/// UI组件合集 ALTComponentItem
@property (nonatomic ,strong)   NSMutableDictionary *componentsDictionary;
/// 视频资源集合 ALTVideoResource
@property (nonatomic ,strong)   NSMutableDictionary *videoSourceDictionary;
/// 图片资源集合 ALTImageSource
@property (nonatomic ,strong)   NSMutableDictionary *imageSourceDictionary;
///
@property (nonatomic ,strong)   NSMutableDictionary *positionAndPts;
/**
 获取当前videoEvent
 */
- (ALTVideoEvent *)currentEvent;

/**
 event向后偏移1
 */
- (void)nextEvent;
- (BOOL)haveNextEvent;

/**
 清空videoEvent执行数据，使nextEvent从第一个videoEvent开始
 */
- (void)resetEventExcute;


/**
 切换视频播放分支
 */
- (void)checkVideoBranch:(NSString *)videoId;
- (ALTVideoEvent *)eventWithEventId:(NSString *)eventId;

- (ALTEventItem *)eventItemWithItemId:(NSString *)itemId;


/**
 起始视频数据
 */
- (ALTVideoResource *)startVideoResource;

- (ALTVideoResource *)currentVideoResource;
@end

NS_ASSUME_NONNULL_END
