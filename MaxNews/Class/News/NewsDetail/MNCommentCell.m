//
//  MNCommentCell.m
//  MaxNews
//
//  Created by luomeng on 16/5/17.
//  Copyright © 2016年 luomeng. All rights reserved.
//

#import "MNCommentCell.h"

@interface MNCommentCell ()
@property (nonatomic, strong) UIImageView *userIcon;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation MNCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initSubViews {
    self.userIcon = [[UIImageView alloc] init];
    
    self.userNameLabel = [[UILabel alloc] init];
    self.userNameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:11];
    self.timeLabel.textColor = UIColorFromRGBA(0, 0, 0, 0.3);
    
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    self.contentLabel.textColor = UIColorFromRGBA(0, 0, 0, 0.5);
    self.contentLabel.numberOfLines = 2;
    
    [self.contentView addSubview:self.userIcon];
    [self.contentView addSubview:self.userNameLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.contentLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat cellW = CGRectGetWidth(self.frame);
    CGFloat cellH = CGRectGetHeight(self.frame);
    
    CGFloat startX = 10;
    CGFloat startY = 15;
    CGFloat iconW = 40;
    self.userIcon.frame = CGRectMake(startX, startY, iconW, iconW);
    self.userIcon.layer.cornerRadius = iconW / 2;
    self.userIcon.clipsToBounds = YES;
    
    CGFloat labelX = CGRectGetMaxX(self.userIcon.frame) + 10;
    CGFloat labelW = cellW - labelX;
    CGFloat nameH = 21;
    self.userNameLabel.frame = CGRectMake(labelX, startY, labelW, nameH);
    
    CGFloat timeH = 15;
    self.timeLabel.frame = CGRectMake(labelX, CGRectGetMaxY(self.userNameLabel.frame) + 2 , labelW, timeH);
    
    CGFloat contentY = CGRectGetMaxY(self.timeLabel.frame) + 1;
    self.contentLabel.frame = CGRectMake(labelX, contentY, labelW, cellH - contentY);
}

- (void)configCellWithComment:(MLObject *)comment {

    MLUser *commenter = comment[@"fromUser"];
    [self.userIcon sd_setImageWithURL:[NSURL URLWithString:[commenter objectForKey:@"iconUrl"]]
                     placeholderImage:ImageNamed(@"default_portrait")];
    self.userNameLabel.text = commenter.username.length ? commenter.username : @"游客";
    self.timeLabel.text = [NSString stringWithFormat:@"发表于：%@", [self formatedStringWithDate:comment.createdAt]];
    self.contentLabel.text = comment[@"commentContent"];
    
}

- (NSString *)formatedStringWithDate:(NSDate *)date {
    NSDate *dateNow = [NSDate date];
    NSString *result = @"";
    
    NSTimeInterval timeInterval = [dateNow timeIntervalSinceDate:date];
    if (timeInterval < 60) {
        result = @"刚刚";
    } else if (timeInterval < 60 * 60) {
        NSInteger mins = (NSInteger)(timeInterval / 60);
        result = [NSString stringWithFormat:@"%ld 分钟前", (long)mins];
    } else if (timeInterval < 24 * 60 * 60) {
        NSInteger hours = (NSInteger)(timeInterval / 3600);
        result = [NSString stringWithFormat:@"%ld 小时前", (long)hours];
    } else {
        result = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    }
    
    return result;
}

@end
