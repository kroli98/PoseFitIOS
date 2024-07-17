#import <CoreVideo/CoreVideo.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** The result from a segmenter operation. */
NS_SWIFT_NAME(SegmentationMask)
@interface MLKSegmentationMask : NSObject

/**
 * The segmentation buffer for the mask.
 *
 * @discussion The buffer will be of format type`kCVPixelFormatType_OneComponent32Float`. Each pixel
 *     in the mask will have a value in range [0.0f, 1.0f] where 1 indicates that a pixel is inside
 *     the segmented region, and 0 indicates that a pixel is outside the segmented region. Callers
 *     may query the mask for per-pixel region-value estimates, but are responsible for defining
 *     their own threshold for intermediate values. The buffer is owned by the `SegmentationMask`
 *     and will be released when the container is deallocated, unless callers explicitly maintain a
 *     reference to it via `CVPixelBufferRetain()`.
 */
@property(nonatomic, readonly) CVPixelBufferRef buffer;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
