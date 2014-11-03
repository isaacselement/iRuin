#import "GameBaseView.h"

@class HeaderView;
@class ContainerView;
@class InteractiveView;

@interface GameView : GameBaseView

@property (strong, readonly) HeaderView* headerView;
@property (strong, readonly) ContainerView* containerView;


@property (strong, readonly) InteractiveView* backActionView;
@property (strong, readonly) InteractiveView* pauseActionView;
@property (strong, readonly) InteractiveView* refreshActionView;
@property (strong, readonly) InteractiveView* chatActionView;


-(NSMutableArray*) symbolsInContainer;

@end
