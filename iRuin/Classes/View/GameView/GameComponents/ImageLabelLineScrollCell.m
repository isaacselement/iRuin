#import "ImageLabelLineScrollCell.h"
#import "AppInterface.h"

//#import "FBShimmeringView.h"

@implementation ImageLabelLineScrollCell
{
//    FBShimmeringView* _shimmeringView;
}

@synthesize imageView;

@synthesize label;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageView = [[UIImageView alloc] initWithFrame: self.bounds];
        [self addSubview: imageView];
        
        label = [[GradientLabel alloc] initWithFrame: self.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview: label];
        
//        _shimmeringView = [[FBShimmeringView alloc] init];
//        _shimmeringView.shimmering = YES;
//        _shimmeringView.shimmeringBeginFadeDuration = 0.3;
//        _shimmeringView.shimmeringOpacity = 0.3;
//        _shimmeringView.contentView = label;
//        [self addSubview:_shimmeringView];
    }
    return self;
}



-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    imageView.frame = self.bounds;
    label.frame = self.bounds;
//    _shimmeringView.frame = self.bounds;
}



@end
