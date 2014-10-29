#import "ChainableState.h"
#import "AppInterface.h"

@implementation ChainableState



#pragma mark - Public Methods
-(void) stateStartChaineVanish
{
    NSMutableArray* vanishSymbols = [self getChaineVanishSymbols];
    
    if (vanishSymbols) {
        [self.effect effectStartVanish: vanishSymbols];
    } else {
        [(ChainableEvent*)ACTION.currentEvent didChainVanish];
    }
}




#pragma mark - SubClass Override Methods

-(NSMutableArray*) getChaineVanishSymbols
{
    int matchCount = MATCH_COUNT;
    if (DATA.config[@"ChaineVanishCount"]) {
        matchCount = [DATA.config[@"ChaineVanishCount"] intValue];
    }
    NSMutableArray* symbols = [SearchHelper searchMatchedInSameLine: matchCount];
    return symbols;
}

@end
