#import "GameScrollView.h"
#import "GradientImageView.h"

@implementation GameScrollView
{
    GradientImageView* backgroundView;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // background image view
        backgroundView = [[GradientImageView alloc] init];
        [self addSubview: backgroundView];
    }
    return self;
}

@end
