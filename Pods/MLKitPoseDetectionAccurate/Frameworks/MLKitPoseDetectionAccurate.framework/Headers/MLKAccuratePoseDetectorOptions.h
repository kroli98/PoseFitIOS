#import <Foundation/Foundation.h>


#import <MLKitPoseDetectionCommon/MLKCommonPoseDetectorOptions.h>

NS_ASSUME_NONNULL_BEGIN

/** Options for specifying a pose detector with more accurate, but larger and slower models. */
NS_SWIFT_NAME(AccuratePoseDetectorOptions)
@interface MLKAccuratePoseDetectorOptions : MLKCommonPoseDetectorOptions

/** Creates a new instance. */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
