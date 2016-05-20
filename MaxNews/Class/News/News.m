//
//  MaxNewsModel.m
//  MaxNews
//
//  Created by luomeng on 16/5/12.
//  Copyright © 2016年 luomeng. All rights reserved.
//

#import "News.h"
#import <MaxLeap/MLObject+Subclass.h>

@implementation News

@dynamic belongCategoryID;
@dynamic whereFrom;
@dynamic newsTitle;
@dynamic contentLink;
@dynamic previewImageLink;
@dynamic standardImageLink;
@dynamic commentCount;
@dynamic isHotNews;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)leapClassName {
    return @"News";
}
@end
