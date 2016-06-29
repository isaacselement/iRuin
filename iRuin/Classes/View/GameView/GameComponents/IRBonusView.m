#import "IRBonusView.h"
#import "AppInterface.h"

@implementation IRBonusView

@synthesize label;

- (instancetype)init
{
    self = [super init];
    if (self) {
        label = [[IRNumberLabel alloc] init];
        [self addSubview: label];
    }
    return self;
}

@end
