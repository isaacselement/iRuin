#import "ImageLabelLineScrollCell.h"
#import "AppInterface.h"

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



@end
