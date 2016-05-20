//
//  MNHotNewsView.m
//  MaxNews
//
//  Created by luomeng on 16/5/13.
//  Copyright © 2016年 luomeng. All rights reserved.
//

#import "MNHotNewsView.h"
#import "News.h"
#import "UIImage+Additions.h"

@interface MNHotNewsView ()
@property (nonatomic, strong) UIView *titleContainer;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation MNHotNewsView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.titleContainer = [[UIView alloc] init];
    self.titleContainer.backgroundColor = UIColorFromRGBA(0, 0, 0, 0.2);
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [self addSubview:self.titleContainer];
    [self.titleContainer addSubview:self.titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGFloat containerH = 30;
    self.titleContainer.frame = CGRectMake(0, height - containerH, width, height);
    self.titleLabel.frame = CGRectMake(15, 0, width - 15, containerH);
}

- (void)configContentWithHotNews:(News *)hotNews {
    NSURL *url = [NSURL URLWithString:hotNews.standardImageLink];
    [self sd_setImageWithURL:url placeholderImage:[UIImage imageWithColor:UIColorFromRGBA(240, 240, 240, 1)]];
    
    self.titleLabel.text = hotNews.newsTitle;
}

@end
