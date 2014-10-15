#import "ChainableState.h"
#import "AppInterface.h"

@implementation ChainableState



#pragma mark - Public Methods
-(void) stateStartChaineVanish
{
    NSMutableArray* vanishSymbols = [SearchHelper searchMatchedInAllSymbols];
    
    if (vanishSymbols) {
        [self.effect effectStartVanish: vanishSymbols];
    } else {
        [(ChainableEvent*)ACTION.currentEvent didChainVanish];
    }
}


@end
