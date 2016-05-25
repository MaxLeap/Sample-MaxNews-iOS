//
//  MNNewsCell.m
//  MaxNews
//
//  Created by luomeng on 16/5/13.
//  Copyright © 2016年 luomeng. All rights reserved.
//

#import "MNNewsCell.h"
#import "News.h"
#import "UIImage+Additions.h"

@interface MNNewsCell ()
@property (nonatomic, strong) UIImageView *newsImageView;
@property (nonatomic, strong) UILabel *newsTitleLabel;
@property (nonatomic, strong) UILabel *whereFromLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@end

@implementation MNNewsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.newsImageView = [[UIImageView alloc] init];
    self.newsImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.newsTitleLabel = [[UILabel alloc] init];
    self.newsTitleLabel.numberOfLines = 3;
    self.newsTitleLabel.font = [UIFont systemFontOfSize:13];
    
    self.whereFromLabel = [[UILabel alloc] init];
    self.whereFromLabel.font = [UIFont systemFontOfSize:10];
    self.whereFromLabel.textColor = UIColorFromRGBA(235, 58, 58, 1);
    self.whereFromLabel.layer.borderColor = UIColorFromRGBA(235, 58, 58, 1).CGColor;
    self.whereFromLabel.layer.borderWidth = 1;
    self.whereFromLabel.layer.cornerRadius = 2;
    self.whereFromLabel.clipsToBounds = YES;
    self.whereFromLabel.textAlignment = NSTextAlignmentCenter;
    
    self.commentLabel = [[UILabel alloc] init];
    self.commentLabel.textAlignment = NSTextAlignmentRight;
    self.commentLabel.font = [UIFont systemFontOfSize:11];
    self.commentLabel.textColor = UIColorFromRGB(0x979797);
    
    [self.contentView addSubview:self.newsImageView];
    [self.contentView addSubview:self.newsTitleLabel];
    [self.contentView addSubview:self.whereFromLabel];
    [self.contentView addSubview:self.commentLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGFloat contentPadding = 10;
    CGFloat contentH = height - contentPadding * 2;
    CGFloat imageW = 93;
    self.newsImageView.frame = CGRectMake(contentPadding, contentPadding, imageW, contentH);
    
    CGFloat bottomLabelH = 13;
    
    CGFloat titleX = CGRectGetMaxX(self.newsImageView.frame) + 10;
    CGFloat titleW = width - titleX - contentPadding;
    CGFloat titleH = height - contentPadding * 2 - 5 - bottomLabelH;
    self.newsTitleLabel.frame = CGRectMake(titleX, contentPadding, titleW, titleH);
    
    CGFloat commentW = 100;
    CGFloat commentX = width - contentPadding - commentW;
    CGFloat commentY = height - contentPadding - bottomLabelH;
    self.commentLabel.frame = CGRectMake(commentX, commentY, commentW, bottomLabelH);
}

- (void)configCellWithNews:(News *)news {
    NSURL *imageUrl = [NSURL URLWithString:news.previewImageLink];
    [self.newsImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageWithColor:UIColorFromRGBA(240, 240, 240, 1)]];
    
    self.newsTitleLabel.text = news.newsTitle;
    
    self.commentLabel.text = [NSString stringWithFormat:@"%ld 评论", (long)news.commentCount];
    
    CGRect rect = [news.whereFrom boundingRectWithSize:CGSizeMake(MAXFLOAT, 10)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:self.whereFromLabel.font}
                                               context:nil];
    CGSize size = rect.size;
    CGFloat labelX = 103 + 10;
    CGFloat labelY = CGRectGetHeight(self.frame) - 10 - 13;
    self.whereFromLabel.frame = CGRectMake(labelX, labelY, size.width + 5, 10 + 3);
    self.whereFromLabel.text = news.whereFrom;
}

@end
