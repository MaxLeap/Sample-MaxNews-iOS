//
//  MLSActivityType.h
//  MaxSocialShare
//
//  Created by Sun Jin on 3/16/16.
//  Copyright © 2016 maxleap. All rights reserved.
//

#ifndef MLSActivityType_h
#define MLSActivityType_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, MLSActivityType) {
    
    /** 其他平台，暂不支持 */
    MLSActivityTypeOther = -1,
    
    /** 初始值 */
    MLSActivityTypeNone = 0,
    
    /** 微信好友 */
    MLSActivityTypeWXSession = 1,
    
    /** 微信朋友圈 */
    MLSActivityTypeWXTimeLine = 2,
    
    /** QQ */
    MLSActivityTypeQQ = 3,
    
    /** QQ 空间 */
    MLSActivityTypeQZone = 4,
    
    /** 新浪微博 */
    MLSActivityTypeWeibo = 5,
    
    /** 任意平台 */
    MLSActivityTypeAny = 99
};

#endif /* MLSActivityType_h */


