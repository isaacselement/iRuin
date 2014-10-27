#import "GameView.h"
#import "AppInterface.h"

@implementation GameView
{
    InteractiveImageView* backActionView;
    InteractiveImageView* pauseActionView;
    InteractiveImageView* refreshActionView;
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
        backActionView = [[InteractiveImageView alloc] init];
        backActionView.didEndTouchAction = ^void(InteractiveImageView* view){
            [ACTION.gameEvent gameBack];
        };
        [self addSubview: backActionView];
        
        pauseActionView = [[InteractiveImageView alloc] init];
        pauseActionView.didEndTouchAction = ^void(InteractiveImageView* view){
            [ACTION.gameEvent gamePause];
        };
        [self addSubview: pauseActionView];
        
        refreshActionView = [[InteractiveImageView alloc] init];
        refreshActionView.didEndTouchAction = ^void(InteractiveImageView* view){
            [ACTION.gameEvent gameRefresh];
        };
        [self addSubview: refreshActionView];
        
    }
    return self;
}


-(NSMutableArray*) symbolsInContainer
{
    return [QueueViewsHelper viewsInVisualArea];
}



@end
