#import <Foundation/Foundation.h>

@class MLKVision3DPoint;

NS_ASSUME_NONNULL_BEGIN

CF_EXTERN_C_BEGIN

/** Defines a pose landmark type. */
typedef NSString *MLKPoseLandmarkType NS_TYPED_ENUM NS_SWIFT_NAME(PoseLandmarkType);

/** The landmark which corresponds to the nose. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeNose;

/** The landmark which corresponds to the left eye inner edge. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeLeftEyeInner;

/** The landmark which corresponds to the left eye. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeLeftEye;

/** The landmark which corresponds to the left eye outer edge. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeLeftEyeOuter;

/** The landmark which corresponds to the right eye inner edge. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeRightEyeInner;

/** The landmark which corresponds to the right eye. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeRightEye;

/** The landmark which corresponds to the right eye outer edge. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeRightEyeOuter;

/** The landmark which corresponds to the left ear. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeLeftEar;

/** The landmark which corresponds to the right ear. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeRightEar;

/** The landmark which corresponds to the left mouth edge. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeMouthLeft;

/** The landmark which corresponds to the right mouth edge. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeMouthRight;

/** The landmark which corresponds to the left shoulder. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeLeftShoulder;

/** The landmark which corresponds to the right shoulder. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeRightShoulder;

/** The landmark which corresponds to the left elbow. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeLeftElbow;

/** The landmark which corresponds to the right elbow. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeRightElbow;

/** The landmark which corresponds to the left wrist. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeLeftWrist;

/** The landmark which corresponds to the right wrist. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeRightWrist;

/** The landmark which corresponds to the pinky finger on the left hand. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeLeftPinkyFinger;

/** The landmark which corresponds to the pinky finger on the right hand. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeRightPinkyFinger;

/** The landmark which corresponds to the index finger on the left hand. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeLeftIndexFinger;

/** The landmark which corresponds to the index finger on the right hand. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeRightIndexFinger;

/** The landmark which corresponds to the left thumb. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeLeftThumb;

/** The landmark which corresponds to the right thumb. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeRightThumb;

/** The landmark which corresponds to the left hip. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeLeftHip;

/** The landmark which corresponds to the right hip. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeRightHip;

/** The landmark which corresponds to the left knee. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeLeftKnee;

/** The landmark which corresponds to the right knee. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeRightKnee;

/** The landmark which corresponds to the left ankle. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeLeftAnkle;

/** The landmark which corresponds to the right ankle. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeRightAnkle;

/** The landmark which corresponds to the left heel. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeLeftHeel;

/** The landmark which corresponds to the right heel. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeRightHeel;

/** The landmark which corresponds to the toe on the left foot. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeLeftToe;

/** The landmark which corresponds to the toe on the right foot. */
extern MLKPoseLandmarkType const MLKPoseLandmarkTypeRightToe;

CF_EXTERN_C_END

/** A landmark in a pose detection result. */
NS_SWIFT_NAME(PoseLandmark)
@interface MLKPoseLandmark : NSObject

/** The landmark type (i.e. location on the body). */
@property(nonatomic, readonly) MLKPoseLandmarkType type;

/**
 * The position of the 3D point in the input image space.
 *
 * The z-value does not have a fixed origin in the image space. Instead, the z-origin is located on
 * the detected person's hip. A negative z-value indicates that the landmark is in front of the
 * z-origin, between the detected person and the camera. Whereas a positive z-value indicates that
 * the landmark is behind the z-origin.
 *
 * Z-values don't have a fixed range. However, since the z-coordinate system is in the input
 * image space, the z-values can be used to infer relative distance between landmarks, measured in
 * image pixels.
 *
 * Note: Z-values are less accurate than x and y-values. Additionally, z-values for facial landmarks
 * are not calculated, so please disregard them.
 */
@property(nonatomic, readonly) MLKVision3DPoint *position;

/** The likelihood, in range [0, 1], that the landmark is actually in the image frame. */
@property(nonatomic, readonly) float inFrameLikelihood;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
