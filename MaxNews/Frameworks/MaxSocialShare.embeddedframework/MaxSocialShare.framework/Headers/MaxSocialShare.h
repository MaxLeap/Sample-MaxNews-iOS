//
//  MaxSocialShare.h
//  MaxSocialShare
//

#import <MaxSocialShare/MLSActivity.h>
#import <MaxSocialShare/MLShareItem.h>
#import <MaxSocialShare/MLSActivityType.h>
#import <MaxSocialShare/MLSActivityViewController.h>

//! Project version number for MaxSocialShare.
FOUNDATION_EXPORT double MaxSocialShareVersionNumber;

//! Project version string for MaxSocialShare.
FOUNDATION_EXPORT const unsigned char MaxSocialShareVersionString[];


@protocol TencentSessionDelegate, WXApiDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface MaxSocialContainer : NSObject

@property (nonatomic, readonly) CGRect rect;
@property (nonatomic, readonly) UIView *view;

@property (nonatomic, readonly) UIBarButtonItem *item;

@property (nonatomic, readonly) UIPopoverArrowDirection arrowDirections; // default is UIPopoverArrowDirectionAny

+ (instancetype)containerWithRect:(CGRect)rect inView:(UIView *)view;
+ (instancetype)containerWithRect:(CGRect)rect inView:(UIView *)view permittedArrowDirectioins:(UIPopoverArrowDirection)arrowDirections;

+ (instancetype)containerWithBarButtonItem:(UIBarButtonItem *)item;

+ (instancetype)containerWithBarButtonItem:(UIBarButtonItem *)item permittedArrowDirectioins:(UIPopoverArrowDirection)arrowDirections;

@end

@interface MaxSocialShare : NSObject

+ (void)shareItem:(MLShareItem *)item completion:(MLSActivityViewControllerCompletionBlock)block;

+ (void)shareItem:(MLShareItem *)item fromView:(nullable UIView *)view completion:(nonnull MLSActivityViewControllerCompletionBlock)block;

+ (void)shareItem:(MLShareItem *)item
         fromBarButtonItem:(nullable UIBarButtonItem *)barButtonItem
       completion:(nonnull MLSActivityViewControllerCompletionBlock)block;

+ (void)shareItem:(MLShareItem *)item withContainer:(nullable MaxSocialContainer *)container completion:(MLSActivityViewControllerCompletionBlock)block;

+ (void)shareText:(NSString *)text completion:(MLSActivityViewControllerCompletionBlock)block;

+ (void)shareWebpageURL:(NSURL *)url completion:(MLSActivityViewControllerCompletionBlock)block;

+ (void)shareImageAtURL:(NSURL *)imageURL completion:(MLSActivityViewControllerCompletionBlock)block;

@end

NS_ASSUME_NONNULL_END

