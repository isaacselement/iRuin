#import "GameBaseView.h"

@class TimerView;
@class ScoreLabel;
@class NormalButton;
@class GradientLabel;
@class ContainerView;
@class FBShimmeringView;

@interface GameView : GameBaseView

@property (strong) TimerView* timerView;
@property (strong) ScoreLabel* scoreLabel;

@property (strong) GradientLabel* seasonLabel;
@property (strong) FBShimmeringView* seasonLabelShimmerView;

@property (strong, readonly) ContainerView* containerView;

@property (strong, readonly) NormalButton* backActionView;
@property (strong, readonly) NormalButton* refreshActionView;

@end
