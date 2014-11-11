#import "GameView.h"
#import "AppInterface.h"

@implementation GameView

@synthesize timerView;
@synthesize scoreLabel;
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
        
        
        // header views
        
        timerView = [[TimerView alloc] init];
        [self addSubview: timerView];
        
        scoreLabel = [[NumberLabel alloc] init];
        [self addSubview: scoreLabel];
        
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
            if (view.selected) {
                [ACTION.gameEvent gamePause];
            } else {
                [ACTION.gameEvent gameResume];
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
