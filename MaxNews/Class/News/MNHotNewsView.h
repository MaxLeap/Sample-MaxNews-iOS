//
//  MNHotNewsView.h
//  MaxNews
//
//  Created by luomeng on 16/5/13.
//  Copyright © 2016年 luomeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class News;
@interface MNHotNewsView : UIImageView

- (void)configContentWithHotNews:(News *)hotNews;

@end
