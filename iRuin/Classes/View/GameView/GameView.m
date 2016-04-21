#import "GameView.h"
#import "AppInterface.h"


@implementation GameView

@synthesize timerView;
@synthesize scoreLabel;

@synthesize seasonLabel;
@synthesize seasonLabelShimmerView;

@synthesize containerView;

@synthesize backActionView;
@synthesize refreshActionView;


- (id)init
{
    self = [super init];
    if (self) {
        // views
        containerView = [[ContainerView alloc] init];
        [self addSubview: containerView];
        
        // timer view
        timerView = [[TimerView alloc] init];
        [self addSubview: timerView];
        timerView.timeIsOverAction = ^void(TimerView* timer) {
            [ACTION.gameEvent gameOver];
        };
        
        // score label
        scoreLabel = [[ScoreLabel alloc] init];
        [self addSubview: scoreLabel];
        
        // season label
        seasonLabel = [[GradientLabel alloc] init];
        seasonLabelShimmerView = [[FBShimmeringView alloc] init];
        seasonLabelShimmerView.contentView = seasonLabel;
        [self addSubview:seasonLabelShimmerView];
        
        // back
        backActionView = [[NormalButton alloc] init];
        backActionView.didTouchUpInsideAction = ^void(NormalButton* sender){
            [ACTION.gameEvent gameBack];
        };
        [self addSubview: backActionView];
        
        // refresh
        refreshActionView = [[NormalButton alloc] init];
        refreshActionView.didTouchUpInsideAction = ^void(NormalButton* sender){
            [ACTION.gameEvent gameReStart];
        };
        [self addSubview: refreshActionView];
        
    }
    return self;
}


@end
