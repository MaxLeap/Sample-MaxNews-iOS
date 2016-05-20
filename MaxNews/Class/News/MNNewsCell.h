//
//  MNNewsCell.h
//  MaxNews
//
//  Created by luomeng on 16/5/13.
//  Copyright © 2016年 luomeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class News;
@interface MNNewsCell : UITableViewCell

- (void)configCellWithNews:(News *)news;

@end
