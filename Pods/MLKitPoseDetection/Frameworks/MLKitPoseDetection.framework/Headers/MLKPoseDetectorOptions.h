#import <Foundation/Foundation.h>


#import <MLKitPoseDetectionCommon/MLKCommonPoseDetectorOptions.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Options for specifying a default pose detector which has a smaller size and runs faster than the
 * accurate model.
 */
NS_SWIFT_NAME(PoseDetectorOptions)
@interface MLKPoseDetectorOptions : MLKCommonPoseDetectorOptions

/** Creates a new instance. */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
