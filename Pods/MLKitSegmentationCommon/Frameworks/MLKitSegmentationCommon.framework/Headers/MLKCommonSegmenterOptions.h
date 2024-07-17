#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

CF_EXTERN_C_BEGIN

/**
 * @enum SegmenterMode
 * Segmenter modes.
 */
typedef NSInteger MLKSegmenterMode NS_TYPED_ENUM NS_SWIFT_NAME(SegmenterMode);

/** Optimized for single static images. */
extern const MLKSegmenterMode MLKSegmenterModeSingleImage;

/**
 * Optimized to expedite the processing of a streaming video by leveraging the results from previous
 * images.
 */
extern const MLKSegmenterMode MLKSegmenterModeStream;

CF_EXTERN_C_END

/** Options for specifying a segmenter. */
NS_SWIFT_NAME(CommonSegmenterOptions)
@interface MLKCommonSegmenterOptions : NSObject

/** The mode for the segmenter. The default value is `.stream`. */
@property(nonatomic) MLKSegmenterMode segmenterMode;

/**
 * Indicates whether the segmenter should output a raw size mask which matches the model output
 * size. If `NO`, the segmenter will upscale the mask using linear interpolation to match the input
 * image dimensions . Defaults to `NO`.
 */
@property(nonatomic) BOOL shouldEnableRawSizeMask;

/** Unavailable. Use the initializer of a subclass. */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
