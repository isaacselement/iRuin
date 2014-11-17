#import "ChainableState.h"
#import "AppInterface.h"

@implementation ChainableState



#pragma mark - Public Methods

-(void) stateStartChaineVanish
{
    // 
    int matchCount = MATCH_COUNT;
    if (DATA.config[@"ChaineVanishCount"]) {
        matchCount = [DATA.config[@"ChaineVanishCount"] intValue];
    }
    
    //
    NSMutableArray* vanishSymbols = [SearchHelper searchMatchedInAllLines: matchCount];
    
    if (vanishSymbols) {
        [self.effect effectStartVanish: vanishSymbols];
    } else {
        [(ChainableEvent*)ACTION.currentEvent eventSymbolsDidChainVanish];
    }
}


@end
