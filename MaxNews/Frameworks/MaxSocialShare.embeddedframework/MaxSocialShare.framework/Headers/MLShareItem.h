//
//  MLSActivityItem.h
//  MaxSocialShare
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, MLSContentMediaType) {
    MLSContentMediaTypeText,
    MLSContentMediaTypeImage,
    MLSContentMediaTypeWebpage,
    MLSContentMediaTypeMusic,
    MLSContentMediaTypeVideo
};

NS_ASSUME_NONNULL_BEGIN

@interface MLShareItem : NSObject

/** @name Properties */

/**
*  Share item id
*/
@property (nullable, nonatomic, readonly) NSUUID *objectId;

/**
 *  The title
 */
@property (nullable, nonatomic, strong) NSString *title;

/**
 *  The description for the item.
 */
@property (nullable, nonatomic, strong) NSString *detail;

/**
 *  The webpage url.
 */
@property (nullable, nonatomic, strong) NSURL *webpageURL;

/**
 *  The data of preview image.
 */
@property (nullable, nonatomic, strong) NSData *previewImageData;

/**
 *  Attachment
 */
@property (nullable, nonatomic, strong) NSURL *attachmentURL;

/**
 *  Content type of the item
 */
@property (nonatomic) MLSContentMediaType mediaType;

/**
 *  Set location for the item
 *
 *  @param latitude  latitude, valid value range is [-90, 90]
 *  @param longitude longitude, valid value range is [-180, 180]
 */
- (void)setLocationWithLatitude:(double)latitude longitude:(double)longitude;

/** @name Constructors */

/**
 *  Instantiate a share item.
 *
 *  @param mediaType The content type of the item
 *
 *  @return A new share item.
 */
- (instancetype)initWithMediaType:(MLSContentMediaType)mediaType;

/** @name Convenience */

/**
 *  Create a share item.
 *
 *  @param mediaType The content type of the item
 *
 *  @return A new share item.
 */
+ (instancetype)itemWithMediaType:(MLSContentMediaType)mediaType;

/**
 *  Create a text share item.
 *
 *  @param title  The title
 *  @param detail Description
 *
 *  @return A new text share item.
 */
+ (instancetype)textItemWithTitle:(nullable NSString *)title detail:(NSString *)detail;

/**
 *  Create a image share item.
 *
 *  @param imageURL The URL
 *  @param title    title
 *  @param detail   description
 *
 *  @return A new image share item.
 */
+ (instancetype)imageItemWithImageURL:(NSURL *)imageURL title:(nullable NSString *)title detail:(nullable NSString *)detail;

/**
 *  Create a webpage share item.
 *
 *  @param imageURL The webpage URL
 *  @param title    title
 *  @param detail   description
 *
 *  @return A new webpage share item.
 */
+ (instancetype)webpageItemWithURL:(NSURL *)url title:(nullable NSString *)title detail:(nullable NSString *)detail;

@end

NS_ASSUME_NONNULL_END


