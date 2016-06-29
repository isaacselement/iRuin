#import "GameBaseView.h"

@class TimerView;
@class IRBonusView;
@class NormalButton;
@class IRNumberLabel;
@class GradientLabel;
@class ContainerView;
@class FBShimmeringView;

@interface GameView : GameBaseView

@property (strong) TimerView* timerView;
@property (strong) IRNumberLabel* vanishViewsAmountLabel;

@property (strong) GradientLabel* seasonLabel;
@property (strong) FBShimmeringView* seasonLabelShimmerView;

@property (strong, readonly) ContainerView* containerView;

@property (strong, readonly) IRBonusView* bonusView;
@property (strong, readonly) NormalButton* backActionView;
@property (strong, readonly) NormalButton* refreshActionView;


@end
