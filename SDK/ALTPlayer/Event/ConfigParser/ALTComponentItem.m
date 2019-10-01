//
//  ALTComponentItem.m
//  ALTSDK
//
//  Created by Alienchang on 2019/4/1.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ALTComponentItem.h"

@implementation ALTComponentItem
- (CGFloat)width {
    if (_width == 0) {
        return 100;
    }
    return _width;
}

- (CGFloat)height {
    if (_height == 0) {
        return 100;
    }
    return _height;
}
@end
