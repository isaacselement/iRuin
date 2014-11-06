#import "HeaderView.h"
#import "AppInterface.h"


@implementation HeaderView


@synthesize timerView;

@synthesize scoreLabel;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        timerView = [[TimerView alloc] init];
        [self addSubview: timerView];
        
        scoreLabel = [[NumberLabel alloc] init];
        [self addSubview: scoreLabel];
    }
    return self;
}


@end
