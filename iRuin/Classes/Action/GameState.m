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

- (void)setVanishAmount:(int)vanishAmount
{
    _vanishAmount = vanishAmount;
    VIEW.gameView.vanishAmountLabel.number = vanishAmount;
}

@end
