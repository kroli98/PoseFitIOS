#import <Foundation/Foundation.h>

#import "MLKPoseLandmark.h"

NS_ASSUME_NONNULL_BEGIN

/** Describes a pose detection result. */
NS_SWIFT_NAME(Pose)
@interface MLKPose : NSObject

/** An array of all the landmarks in the detected pose. */
@property(nonatomic, readonly) NSArray<MLKPoseLandmark *> *landmarks;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Returns the landmark which corresponds to a given type.
 *
 * @param type The type of the landmark which should be returned.
 * @return The landmark which corresponds to `type`.
 */
- (MLKPoseLandmark *)landmarkOfType:(MLKPoseLandmarkType)type;

@end

NS_ASSUME_NONNULL_END
