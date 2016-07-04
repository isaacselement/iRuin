#import "ImageLabelLineScrollCell.h"
#import "AppInterface.h"

@interface ImageLabelLineScrollCell ()

@property (strong, nonatomic) CAGradientLayer* maskLayer;

@property (strong) CAShapeLayer* maskLayerUp;
@property (strong) CAShapeLayer* maskLayerDown;


@end

@implementation ImageLabelLineScrollCell

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
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    imageView.frame = self.bounds;
    label.frame = self.bounds;
}


#pragma mark - 

-(void) startMaskEffect
{
    self.layer.mask = self.maskLayer;
    [ACTION.gameEffect designateValuesActionsTo: self config:DATA.config[@"Chapter_Cell_In_The_Last"]];
}

-(void) stopMaskEffect
{
    self.layer.mask = nil;
    [self.maskLayer removeAllAnimations];
}

- (CAGradientLayer *)maskLayer
{
    if (!_maskLayer) {
        _maskLayer = [CAGradientLayer layer];
        _maskLayer.frame = self.layer.bounds;
    }
    return _maskLayer;
}

@end
