//
//  MLSActivity.h
//  MaxSocialShare
//
//  Created by Sun Jin on 3/15/16.
//  Copyright © 2016 maxleap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLSActivityType.h"
#import "MLShareItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLSActivity : NSObject

///------------------------------------
///  @name override methods
///------------------------------------

+ (MLSActivityType)type;       // default returns nil. subclass may override to return custom activity type that is reported to completion handler

+ (BOOL)canPerformWithActivityItem:(MLShareItem *)activityItem;   // override this to return availability of activity based on item. default returns NO

- (nullable NSString *)title;      // default returns nil. subclass must override and must return non-nil value
- (nullable UIImage *)image;       // default returns nil. subclass must override and must return non-nil value

- (void)prepareWithActivityItem:(MLShareItem *)activityItem;      // override to extract items and set up your HI. default does nothing

- (nullable UIViewController *)activityViewController;   // return non-nil to have view controller presented modally. call activityDidFinish at end. default returns nil
- (void)perform;                        // if no view controller, this method is called. call activityDidFinish when done. default calls [self activityDidFinish:NO]

///----------------------------------
/// @name state method
///----------------------------------

- (void)activityDidFinishWithError:(nullable NSError *)error NS_REQUIRES_SUPER;   // activity must call this when activity is finished

///-----------------------------------
/// @name manage activity subclasses
///-----------------------------------

+ (void)registerActivityClass:(Class)activityClass;

+ (NSArray<MLSActivity*> *)activitiesCanPerformWithActivityItem:(MLShareItem *)activityItem excludedActivityTypes:(nullable NSArray<NSNumber*> *)excludedActivityTypes;

@end

NS_ASSUME_NONNULL_END


