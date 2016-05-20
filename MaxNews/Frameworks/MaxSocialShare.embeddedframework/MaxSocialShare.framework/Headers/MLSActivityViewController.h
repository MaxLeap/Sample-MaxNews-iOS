//
//  MLSActivityViewController.h
//  MaxSocialShare
//
//  Created by Sun Jin on 3/16/16.
//  Copyright © 2016 maxleap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MaxSocialShare/MLSActivity.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^MLSActivityViewControllerCompletionBlock)(MLSActivityType activityType, BOOL completed, NSError * __nullable activityError);

@interface MLSActivityViewController : UIViewController

- (instancetype)initWithItem:(MLShareItem *)item NS_DESIGNATED_INITIALIZER;

@property (nullable, nonatomic, copy) MLSActivityViewControllerCompletionBlock completionHandler;

@property (nullable, nonatomic, copy) NSArray<NSNumber*> *excludedActivityTypes;


- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

