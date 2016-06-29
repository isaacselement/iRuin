#import "GameState.h"
#import "AppInterface.h"

@implementation GameState

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)resetStatus
{
    self.currentChapter = 0;
    self.currentMode = nil;
    self.vanishCount = 0;
    self.continuousCount = 0;
    self.vanishViewsAmount = 0;
}

- (void)setContinuousCount:(int)continuousCount
{
    _continuousCount = continuousCount;
    
    if (continuousCount == 0) return;
    
    IRBonusView* bonusView = VIEW.gameView.bonusView;
    if (bonusView.label.number < continuousCount) bonusView.label.number = continuousCount;
    
    IRNumberLabel* effectLabel = [[IRNumberLabel alloc] init];
    effectLabel.text = [NSString stringWithFormat:@"%d", continuousCount];
    [bonusView addSubview:effectLabel];
    effectLabel.frame = effectLabel.superview.bounds;
    [ACTION.gameEffect designateValuesActionsTo:effectLabel config:DATA.config[@"Caculate_Continuous"] completion:^{
        [effectLabel removeFromSuperview];
    }];
}

- (void)setVanishViewsAmount:(int)vanishViewsAmount
{
    _vanishViewsAmount = vanishViewsAmount;
    VIEW.gameView.vanishViewsAmountLabel.number = vanishViewsAmount;
}

@end
