#import "GameView.h"
#import "AppInterface.h"

@implementation GameView
{
    InteractiveView* backActionView;
    InteractiveView* pauseActionView;
    InteractiveView* refreshActionView;
    InteractiveView* chatActionView;
}

@synthesize headerView;
@synthesize containerView;

- (id)init
{
    self = [super init];
    if (self) {
        // views
        containerView = [[ContainerView alloc] init];
        [self addSubview: containerView];
        
        headerView = [[HeaderView alloc] init];
        [self addSubview: headerView];
        
        // action views
        
        
        // back
        backActionView = [[InteractiveView alloc] init];
        backActionView.imageView.didEndTouchAction = ^void(InteractiveImageView* view){
            [ACTION.gameEvent gameBack];
        };
        [self addSubview: backActionView];
        
        
        // pause
        pauseActionView = [[InteractiveView alloc] init];
        pauseActionView.imageView.didEndTouchAction = ^void(InteractiveImageView* view){
            [ACTION.gameEvent gamePause];
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


-(NSMutableArray*) symbolsInContainer
{
    return [QueueViewsHelper viewsInVisualArea];
}



@end
