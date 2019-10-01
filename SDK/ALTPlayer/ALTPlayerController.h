//
//  ALTPlayerController.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/21.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ALTControllerListener.h"
#import "ALTEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALTPlayerController : NSObject 
@property (nonatomic ,weak) id  <ALTPlayerControllerDelegate> delegate;
@property (nonatomic ,assign)   float rate;
@property (nonatomic ,readonly) int   fps;
@property (nonatomic ,assign)   float volume;
//@property (nonatomic ,assign)   int   

- (void)audioPause;
- (void)audioStop;
- (void)audioResume;

- (void)videoPause;
- (void)videoStop;
- (void)videoResume;

- (void)resetData;
/**
 视频截图
 */
- (UIImage *)videoShort;
- (void)syncVideoShort:(void(^)(UIImage *shortImage))callBack;

/**
 初始化，需要显示的位置与载体view
 */
- (instancetype)initWithFrame:(CGRect)frame
                  containView:(UIView *)containView;

/**
 根据项目id 和集id初始化
 @param parsed 配置文件解析完成回调
 */
- (void)playWithProjectId:(NSString *)projectId
                episodeId:(NSString *)episodeId
             configParsed:(void(^)(BOOL success))parsed;

- (void)playWithUrl:(NSString *)url;
- (void)playWithUrl:(NSString *)url
           callBack:(void (^)(ALT_ENUM_PLAYEVENT event))callBack;
- (void)playAudio:(NSString *)audioUrl;


/****** 缓存相关 ******/
+ (void)initCache;
+ (unsigned long long)calculateCachedSizeWithError:(NSError **)error;
+ (void)cleanAllCacheWithError:(NSError **)error;
+ (void)cleanCacheForURL:(NSURL *)url
                   error:(NSError **)error;
+ (NSString *)localPathWithUrl:(NSString *)url;
+ (NSArray <NSString *>*)cachedList;
+ (NSArray <NSString *>*)cachedUrls;
/**
 重新布局
 */
- (void)reLayout;

@end

NS_ASSUME_NONNULL_END
