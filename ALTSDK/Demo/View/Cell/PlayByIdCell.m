//
//  PlayByIdCell.m
//  ALTSDK
//
//  Created by Alienchang on 2019/4/23.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "PlayByIdCell.h"

@implementation PlayByIdCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.projectTextField];
        [self.contentView addSubview:self.episodeTextField];
        [self.contentView addSubview:self.playButton];
        [self.projectTextField setPlaceholder:@"project id"];
        [self.episodeTextField setPlaceholder:@"episode id"];
        [self.projectTextField setFrame:CGRectMake(0, 0, 80, 44)];
        [self.episodeTextField setFrame:CGRectMake(90, 0, 80, 44)];
        [self.playButton setFrame:CGRectMake(180, 0, 80, 44)];
        [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
        [self.playButton setBackgroundColor:[UIColor redColor]];
    }
    return self;
}

- (UITextField *)projectTextField {
    if (!_projectTextField) {
        _projectTextField = [UITextField new];
    }
    return _projectTextField;
}

- (UITextField *)episodeTextField {
    if (!_episodeTextField) {
        _episodeTextField = [UITextField new];
    }
    return _episodeTextField;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton new];
    }
    return _playButton;
}


@end
