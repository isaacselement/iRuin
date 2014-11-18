#import "ChainableState.h"
#import "AppInterface.h"

@implementation ChainableState



#pragma mark - Public Methods

-(void) stateStartChaineVanish
{
    
    // match count
    int matchCount = MATCH_COUNT;
    if (DATA.config[@"ChaineVanishCount"]) {
        matchCount = [DATA.config[@"ChaineVanishCount"] intValue];
    }
    
    // get symbols and start
    NSMutableArray* vanishSymbols = [SearchHelper searchMatchedInAllLines: matchCount];
    
    if (vanishSymbols) {
        
        ACTION.gameState.isChainVanishing = YES;
        
        [self.effect effectStartVanish: vanishSymbols];
        
    } else {
        
        ACTION.gameState.isChainVanishing = NO;
        
        [(ChainableEvent*)ACTION.currentEvent eventSymbolsDidChainVanish];
        
    }
    
    
}


@end
