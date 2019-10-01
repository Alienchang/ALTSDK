//
//  ImageViewController.m
//  ALTSDK
//
//  Created by Alienchang on 2019/3/21.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.imageView];
    [self.imageView setFrame:self.view.bounds];
    // Do any additional setup after loading the view.
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    return _imageView;
}

@end
