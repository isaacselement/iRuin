#import "FrameManager.h"

@implementation FrameManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.blackPoint = CGPointMake(-250, -250);
    }
    return self;
}

@end
