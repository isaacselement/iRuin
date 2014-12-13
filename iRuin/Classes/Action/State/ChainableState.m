#import "ChainableState.h"
#import "AppInterface.h"

@implementation ChainableState
{
    // continuously chain vanish number 
    int continuous;
}

#pragma mark - Public Methods

-(void) stateStartChainVanish
{
    // get symbols ...
    NSMutableArray* vanishSymbols = [SearchHelper searchMatchedInAllLines: MATCH_COUNT];
    
    
    // check if end chain vanish ~~~
    BOOL noVanishViews = vanishSymbols == nil;
    BOOL isContainsNull = [QueueViewsHelper isViewsInVisualAreaContains: [NSNull null]];
    if (noVanishViews && !isContainsNull) {
        
        // the first time check , no chain vanish , so should check vanishing~~~
        if (ACTION.gameState.isChainVanishing) {
            [(ChainableEvent*)ACTION.currentEvent eventSymbolsDidChainVanish];
            ACTION.gameState.isChainVanishing = NO;
            
            continuous = 0;
        }
        
        return;
    }
    
    if (vanishSymbols) {
        continuous++;
    }
    
    
    //TODO: ---------------- temp code here ----------------------------------------------
//    if (vanishSymbols) {
//        int bonusScore = vanishSymbols.count * continuous;
//        [[EffectHelper getInstance] bonusEffectWithScore: bonusScore];
//    }
    //TODO: ---------------- temp code here ----------------------------------------------
    
    
    // then start , the vanish symbols maybe nil ~~~
    DLog(@"--- stateStartChainVanish");
    ACTION.gameState.isChainVanishing = YES;
    [self.effect effectStartVanish: vanishSymbols];
    
    
    
    
    
    
}



@end

