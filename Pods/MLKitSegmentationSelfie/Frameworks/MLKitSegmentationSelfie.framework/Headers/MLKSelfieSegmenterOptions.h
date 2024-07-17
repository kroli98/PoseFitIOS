#import <Foundation/Foundation.h>


#import <MLKitSegmentationCommon/MLKCommonSegmenterOptions.h>

NS_ASSUME_NONNULL_BEGIN

/** Options for specifying a segmenter for selfie portraits. */
NS_SWIFT_NAME(SelfieSegmenterOptions)
@interface MLKSelfieSegmenterOptions : MLKCommonSegmenterOptions

/** Creates a new instance. */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
