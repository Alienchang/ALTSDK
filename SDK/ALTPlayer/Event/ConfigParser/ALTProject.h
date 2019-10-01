//
//  ALTProjet.h
//  ALTSDK
//
//  Created by Alienchang on 2019/3/25.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ALTEventConst.h"
NS_ASSUME_NONNULL_BEGIN

@interface ALTProject : NSObject

@property (nonatomic ,copy)   NSString *projectId;
@property (nonatomic ,copy)   NSString *projectName;     /// 产品填表用，实际配置可能是空
@property (nonatomic ,copy)   NSString *projectDesc;     /// 产品填表用，实际配置可能是空
@property (nonatomic ,copy)   NSString *episodeId;       /// 本集ID
@property (nonatomic ,copy)   NSString *episodeName;     /// 本集名称，产品填表用，实际配置可能是空
@property (nonatomic ,copy)   NSString *episodeDesc;     /// 本集描述，产品填表用，实际配置可能是空
@property (nonatomic ,copy)   NSString *startViewId;     /// 开始界面ID，视频自动播放时开始界面将不需要出现
@property (nonatomic ,copy)   NSString *startVideoId;    /// 开始视频ID
@property (nonatomic ,strong) NSNumber *videoBitrate;    /// 视频码率
@property (nonatomic ,strong) NSNumber *stageWidth;      /// UI舞台宽度
@property (nonatomic ,strong) NSNumber *stageHeight;     /// UI舞台高度
@property (nonatomic ,copy)   ALTContenFitType stageFit; /// 舞台填充模式，contain|cover
@property (nonatomic ,copy)   ALTContenFitType videoFit; /// 视频填充模式，contain|cover
@property (nonatomic ,copy)   NSString *videoBaseUrl;    /// 视频基础路径
@property (nonatomic ,copy)   NSString *imageBaseUrl;    /// 图片基础路径
@property (nonatomic ,copy)   NSString *audioBaseUrl;    /// 音频基础路径
@property (nonatomic ,copy)   NSString *otherBaseUrl;    /// 其它资源基础路径
/// 视频宽高，需要手动设置，便于其它模块使用
@property (nonatomic ,assign) CGFloat playerWidth;
@property (nonatomic ,assign) CGFloat playerHeight;
@property (nonatomic ,assign) int     fps;
@end


NS_ASSUME_NONNULL_END
