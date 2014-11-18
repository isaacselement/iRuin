#import "GameView.h"
#import "AppInterface.h"

@implementation GameView
{
    FBShimmeringView* shimmeringView;
}

@synthesize timerView;
@synthesize scoreLabel;
@synthesize modeLabel;
@synthesize containerView;

@synthesize backActionView;
@synthesize pauseActionView;
@synthesize refreshActionView;
@synthesize chatActionView;


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
        scoreLabel = [[NumberLabel alloc] init];
        [self addSubview: scoreLabel];
        
        // mode label
        modeLabel = [[GradientLabel alloc] init];
        shimmeringView = [[FBShimmeringView alloc] init];
        shimmeringView.contentView = modeLabel;
        [self addSubview:shimmeringView];
        
        
        // action views
        
        
        // back
        backActionView = [[InteractiveView alloc] init];
        backActionView.imageView.didEndTouchAction = ^void(InteractiveImageView* view){
            [ACTION.gameEvent gameBack];
        };
        [self addSubview: backActionView];
        
        
        // pause
        pauseActionView = [[InteractiveView alloc] init];
        pauseActionView.imageView.enableSelected = YES;
        pauseActionView.imageView.didEndTouchAction = ^void(InteractiveImageView* view){
            // view.selected == NO is the paus image. 
            // pause , forbid the timer not begin and tap pause
            BOOL isTimerPausing = [VIEW.gameView.timerView isPausing];
            
            if (view.selected) {
                if (isTimerPausing) {
                    view.selected = !view.selected;
                } else {
                    [VIEW.gameView.timerView pauseTimer];
                    [ACTION.gameEvent gamePause];
                }
            } else {
                if (isTimerPausing) {
                    [VIEW.gameView.timerView startTimer];
                    [ACTION.gameEvent gameResume];
                } else {
                    view.selected = !view.selected;
                }
            }
        };
        [self addSubview: pauseActionView];
        
        
        // refresh
        refreshActionView = [[InteractiveView alloc] init];
        refreshActionView.imageView.didEndTouchAction = ^void(InteractiveImageView* view){
            [ACTION.gameEvent gameRefresh];
        };
        [self addSubview: refreshActionView];
        
        
        // chat
        chatActionView = [[InteractiveView alloc] init];
        chatActionView.imageView.didEndTouchAction = ^void(InteractiveImageView* view) {
            [ACTION.gameEvent gameChat];
        };
        [self addSubview: chatActionView];
    }
    return self;
}


@end
