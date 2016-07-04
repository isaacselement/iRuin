#import "GameState.h"
#import "AppInterface.h"

@implementation GameState

@synthesize continuousCount;

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
    VIEW.gameView.bonusView.label.number = 0;
}

- (void)setVanishViewsAmount:(int)vanishViewsAmount
{
    _vanishViewsAmount = vanishViewsAmount;
    VIEW.gameView.vanishViewsAmountLabel.number = vanishViewsAmount;
}


- (void)startBonusEffect: (int)count
{
    if (VIEW.gameView.bonusView.label.number < count) VIEW.gameView.bonusView.label.number = count;
    
    IRNumberLabel* effectLabel = [[IRNumberLabel alloc] init];
    effectLabel.text = [NSString stringWithFormat:@"%d", count];
    [VIEW.gameView.bonusView addSubview:effectLabel];
    effectLabel.frame = effectLabel.superview.bounds;
    [ACTION.gameEffect designateValuesActionsTo:effectLabel config:DATA.config[@"Caculate_Continuous"] completion:^{
        [effectLabel removeFromSuperview];
    }];
}

@end
