//
//  ALTComponentProtocol.h
//  ALTSDK
//
//  Created by Alienchang on 2019/6/5.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#ifndef ALTComponentProtocol_h
#define ALTComponentProtocol_h
#import "ALTProjectDataSource.h"
#import "ALTComponentItem.h"
@protocol ALTComponentProtocol <NSObject>

@property (nonatomic ,assign) CGFloat duration;
@property (nonatomic ,strong) ALTProjectDataSource *projectDataSource;
@property (nonatomic ,strong) ALTComponentItem *componentItem;
@end

#endif /* ALTComponentProtocol_h */
