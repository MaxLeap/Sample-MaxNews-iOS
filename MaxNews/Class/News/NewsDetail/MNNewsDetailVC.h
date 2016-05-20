//
//  MNNewsDetailVC.h
//  MaxNews
//
//  Created by luomeng on 16/5/13.
//  Copyright © 2016年 luomeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CommentNewsSuccessBlock)();

@class News;
@interface MNNewsDetailVC : UIViewController

@property (nonatomic, strong) News *newsToShow;
@property (nonatomic, copy) CommentNewsSuccessBlock commentSuccessBlock;

@end
