//
//  MNCommentListCell.m
//  MaxNews
//
//  Created by luomeng on 16/5/16.
//  Copyright © 2016年 luomeng. All rights reserved.
//

#import "MNCommentListCell.h"

@interface MNCommentListCell ()
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *commentedNewsInfo;
@end

@implementation MNCommentListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.numberOfLines = 2;
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    
    self.commentedNewsInfo = [[UILabel alloc] init];
    self.commentedNewsInfo.userInteractionEnabled = YES;
    self.commentedNewsInfo.numberOfLines = 2;
    self.commentedNewsInfo.font = [UIFont systemFontOfSize:14];
    
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.commentedNewsInfo];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat padding = 10;
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat contentH = (height - padding * 2 - 5) / 2;
    self.contentLabel.frame = CGRectMake(padding, padding, (width -padding * 2), contentH);
    self.commentedNewsInfo.frame = CGRectMake(padding, CGRectGetMaxY(self.contentLabel.frame) + 5, (width - padding * 2), contentH);
}

- (void)updateContentWithCommentObj:(MLObject *)commentObj {
    MLObject *newsObj = commentObj[@"commentedNews"];
    NSString *title = newsObj[@"newsTitle"];
    
    NSString *content = commentObj[@"commentContent"];
    NSDate *createAt = commentObj.createdAt;
    NSString *time = [self formatedStringWithDate:createAt];
    
    self.contentLabel.text = [NSString stringWithFormat:@"%@ -> %@", time, content];
    self.commentedNewsInfo.text = [NSString stringWithFormat:@"  [原文] %@", title];
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
