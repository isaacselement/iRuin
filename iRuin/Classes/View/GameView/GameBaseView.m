#import "GameBaseView.h"

@implementation GameBaseView
{
    UIImageView* backgroundView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // background image view
        backgroundView = [[UIImageView alloc] init];
        [self addSubview: backgroundView];
    }
    return self;
}




@end
