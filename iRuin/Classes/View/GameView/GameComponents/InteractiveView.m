#import "InteractiveView.h"
#import "InteractiveImageView.h"

@implementation InteractiveView


@synthesize imageView;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageView = [[InteractiveImageView alloc] init];
        imageView.frame = self.bounds;
        [self addSubview: imageView];
    }
    return self;
}


-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    imageView.frame = self.bounds;
}


@end
