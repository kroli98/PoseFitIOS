#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

CF_EXTERN_C_BEGIN

/**
 * @enum PoseDetectorMode
 * Pose detector modes.
 */
typedef NSInteger MLKPoseDetectorMode NS_TYPED_ENUM NS_SWIFT_NAME(PoseDetectorMode);

/** Optimized for single static images. */
extern const MLKPoseDetectorMode MLKPoseDetectorModeSingleImage;

/**
 * Optimized to expedite the processing of a streaming video by leveraging the results from previous
 * images.
 */
extern const MLKPoseDetectorMode MLKPoseDetectorModeStream;

CF_EXTERN_C_END

/** Options for specifying a pose detector. */
NS_SWIFT_NAME(CommonPoseDetectorOptions)
@interface MLKCommonPoseDetectorOptions : NSObject

/** The mode for the pose detector. The default value is `.stream`. */
@property(nonatomic) MLKPoseDetectorMode detectorMode;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
