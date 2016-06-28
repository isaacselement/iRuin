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
    self.vanishViewsAmount = 0;
}

- (void)setVanishAmount:(int)vanishViewsAmount
{
    _vanishViewsAmount = vanishViewsAmount;
    VIEW.gameView.vanishViewsAmountLabel.number = vanishViewsAmount;
}

@end
