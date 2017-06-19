//
//  ZZCollectionViewCell.m
//  ZZCollectionViewWaterfallLayout
//
//  Created by qdhl on 2017/6/16.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZZCollectionViewCell.h"

@implementation ZZCollectionViewCell
- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
    }
    return self;
}
@end
