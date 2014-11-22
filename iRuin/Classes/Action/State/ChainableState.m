#import "ChainableState.h"
#import "AppInterface.h"

@implementation ChainableState


#pragma mark - Public Methods

-(void) stateStartChainVanish
{
    // get symbols ...
    NSMutableArray* vanishSymbols = [SearchHelper searchMatchedInAllLines: MATCH_COUNT];
    
    // check if end chain vanish ~~~
    BOOL noVanishViews = vanishSymbols == nil;
    BOOL isContainsNull = [QueueViewsHelper isViewsInVisualAreaContains: [NSNull null]];
    if (noVanishViews && !isContainsNull) {
        if (ACTION.gameState.isChainVanishing) {
            [(ChainableEvent*)ACTION.currentEvent eventSymbolsDidChainVanish];
        }
        ACTION.gameState.isChainVanishing = NO;
        return;
    }
    
    // then start , the vanish symbols maybe nil ~~~
    DLog(@"--- stateStartChainVanish");
    ACTION.gameState.isChainVanishing = YES;
    [self.effect effectStartVanish: vanishSymbols];
}


@end
