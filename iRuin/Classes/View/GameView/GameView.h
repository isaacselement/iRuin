#import "GameBaseView.h"

@class TimerView;
@class NumberLabel;
@class ContainerView;
@class InteractiveView;

@interface GameView : GameBaseView

@property (strong) TimerView* timerView;
@property (strong) NumberLabel* scoreLabel;
@property (strong, readonly) ContainerView* containerView;


@property (strong, readonly) InteractiveView* backActionView;
@property (strong, readonly) InteractiveView* pauseActionView;
@property (strong, readonly) InteractiveView* refreshActionView;
@property (strong, readonly) InteractiveView* chatActionView;


-(NSMutableArray*) symbolsInContainer;

@end
