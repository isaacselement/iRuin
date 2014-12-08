#import "GameBaseView.h"


@class GradientLabel;
@class LineScrollView;
@class FBShimmeringView;


@interface ChaptersView : GameBaseView



@property (strong, readonly) LineScrollView* lineScrollView;

@property (strong, readonly) GradientLabel* cueLabel;
@property (strong, readonly) FBShimmeringView* cueLabelShimmerView;


@end
