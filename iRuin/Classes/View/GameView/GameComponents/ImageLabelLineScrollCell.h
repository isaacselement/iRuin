#import "LineScrollViewCell.h"


@class  GradientLabel;


@interface ImageLabelLineScrollCell : LineScrollViewCell


@property (strong, readonly) UIImageView* imageView;

@property (strong, readonly) GradientLabel* label;


#pragma mark -

-(void) startMaskEffect;

-(void) stopMaskEffect;

@end
