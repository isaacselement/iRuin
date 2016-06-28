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

- (void)setVanishAmount:(int)vanishViewsAmount
{
    _vanishViewsAmount = vanishViewsAmount;
    VIEW.gameView.vanishViewsAmountLabel.number = vanishViewsAmount;
}

@end
