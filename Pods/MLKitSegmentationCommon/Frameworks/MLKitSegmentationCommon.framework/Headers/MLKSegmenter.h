#import <Foundation/Foundation.h>

@class MLKCommonSegmenterOptions;
@class MLKSegmentationMask;

@protocol MLKCompatibleImage;

NS_ASSUME_NONNULL_BEGIN

/**
 * A block containing the segmentation mask or `nil` if there's an error.
 *
 * @param mask The mask from the image or `nil` if there was an error.
 * @param error The error or `nil`.
 */
typedef void (^MLKSegmentationCallback)(MLKSegmentationMask *_Nullable mask,
                                        NSError *_Nullable error)
    NS_SWIFT_NAME(SegmentationCallback);

/** A detector that performs segmentation on input images. */
NS_SWIFT_NAME(Segmenter)
@interface MLKSegmenter : NSObject

/**
 * Returns a segmenter with the given options.
 *
 * @param options Options for configuring the segmenter.
 * @return A segmenter configured with the given options.
 */
+ (instancetype)segmenterWithOptions:(MLKCommonSegmenterOptions *)options
    NS_SWIFT_NAME(segmenter(options:));

/** Unavailable. Use the class methods. */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Processes the given image for segmentation.
 *
 * @param image The image to process.
 * @param completion Handler to call back on the main thread with the segmentation mask or error.
 */

- (void)processImage:(id<MLKCompatibleImage>)image
          completion:(MLKSegmentationCallback)completion NS_SWIFT_NAME(process(_:completion:));

/**
 * Returns the segmentation mask in the given image or `nil` if there was an error. The segmentation
 * is performed synchronously on the calling thread.
 *
 * @discussion It is advised to call this method off the main thread to avoid blocking the UI. As a
 *     result, an `NSException` is raised if this method is called on the main thread.
 * @param image The image to get results in.
 * @param error An optional error parameter populated when there is an error getting results.
 * @return The segmentation mask in the given image or `nil` if there was an error.
 */

- (nullable MLKSegmentationMask *)resultsInImage:(id<MLKCompatibleImage>)image
                                           error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
