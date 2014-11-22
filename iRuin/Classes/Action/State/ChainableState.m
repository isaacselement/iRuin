#import "ChainableState.h"
#import "AppInterface.h"

@implementation ChainableState



#pragma mark - Public Methods

-(void) stateStartChainVanish
{
    
    int matchCount = MATCH_COUNT;
    if (DATA.config[@"ChaineVanishCount"]) {
        matchCount = [DATA.config[@"ChaineVanishCount"] intValue];
    }
    
    // get symbols and start vanish
    NSMutableArray* vanishSymbols = [SearchHelper searchMatchedInAllLines: matchCount];
    
    if (vanishSymbols) {
        ACTION.gameState.isChainVanishing = YES;
        
        DLog(@"---------- ChainVanish YES");
        
        [self.effect effectStartVanish: vanishSymbols];
        
    } else {
        ACTION.gameState.isChainVanishing = NO;

        DLog(@"---------- ChainVanish NO");
        
        [(ChainableEvent*)ACTION.currentEvent eventSymbolsDidChainVanish];
    }
    
}


@end
