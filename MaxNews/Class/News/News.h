//
//  MaxNewsModel.h
//  MaxNews
//
//  Created by luomeng on 16/5/12.
//  Copyright © 2016年 luomeng. All rights reserved.
//

#import <MaxLeap/MaxLeap.h>

@interface News : MLObject <MLSubclassing>
// 子类化 MLObject，必须实现该方法，返回MaxLeap云平台对应的表名
+ (NSString *)leapClassName;

// 定义属性 与 MaxLeap 云平台表格字段对应(名字与表格字段名对应)
@property (nonatomic, copy) NSString *belongCategoryID;
@property (nonatomic, copy) NSString *whereFrom;
@property (nonatomic, copy) NSString *newsTitle;
@property (nonatomic, copy) NSString *contentLink;
@property (nonatomic, copy) NSString *previewImageLink;
@property (nonatomic, copy) NSString *standardImageLink;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, assign) BOOL isHotNews;
@end
