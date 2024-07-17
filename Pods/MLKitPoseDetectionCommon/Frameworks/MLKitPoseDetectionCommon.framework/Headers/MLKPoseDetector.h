#import <Foundation/Foundation.h>

@class MLKCommonPoseDetectorOptions;
@class MLKPose;

@protocol MLKCompatibleImage;

NS_ASSUME_NONNULL_BEGIN

/**
 * A block containing the pose detection results.
 *
 * @param poses The array of poses detected in the given image or `nil` if there was an error. If no
 *     poses are detected, then an empty array will be returned.
 * @param error The error or `nil`.
 */
typedef void (^MLKPoseDetectionCallback)(NSArray<MLKPose *> *_Nullable poses,
                                         NSError *_Nullable error)
    NS_SWIFT_NAME(PoseDetectionCallback);

/** A detector for performing body-pose estimation. */
NS_SWIFT_NAME(PoseDetector)
@interface MLKPoseDetector : NSObject

/**
 * Returns a pose detector with the given options.
 *
 * @param options Options for configuring the pose detector.
 * @return A pose detector configured with the given options.
 */
+ (instancetype)poseDetectorWithOptions:(MLKCommonPoseDetectorOptions *)options
    NS_SWIFT_NAME(poseDetector(options:));

/** Unavailable. Use the class methods. */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Processes the given image for pose detection.
 *
 * @param image The image to process.
 * @param completion Handler to call back on the main thread with pose detected or error.
 */

- (void)processImage:(id<MLKCompatibleImage>)image
          completion:(MLKPoseDetectionCallback)completion NS_SWIFT_NAME(process(_:completion:));

/**
 * Returns the pose results in the given image. The pose detection is performed synchronously on
 * the calling thread.
 *
 * @discussion It is advised to call this method off the main thread to avoid blocking the UI. As a
 *     result, an `NSException` is raised if this method is called on the main thread.
 * @param image The image to get results in.
 * @param error An optional error parameter populated when there is an error getting results.
 * @return The array of poses detected in the given image or `nil` if there was an error.
 *     If no poses are detected, then an empty array will be returned.
 */

- (nullable NSArray<MLKPose *> *)resultsInImage:(id<MLKCompatibleImage>)image
                                          error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
