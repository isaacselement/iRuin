#import "GameBaseView.h"

@class TimerView;
@class NumberLabel;
@class GradientLabel;
@class ContainerView;
@class InteractiveView;
@class FBShimmeringView;

@interface GameView : GameBaseView

@property (strong) TimerView* timerView;
@property (strong) NumberLabel* scoreLabel;

@property (strong) GradientLabel* seasonLabel;
@property (strong) FBShimmeringView* seasonLabelShimmerView;

@property (strong, readonly) ContainerView* containerView;


@property (strong, readonly) InteractiveView* backActionView;
@property (strong, readonly) InteractiveView* pauseActionView;
@property (strong, readonly) InteractiveView* refreshActionView;
@property (strong, readonly) InteractiveView* chatActionView;

@end
