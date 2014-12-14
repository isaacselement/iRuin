#import "ChainableState.h"
#import "AppInterface.h"

@implementation ChainableState
{
    // continuously chain vanish number 
    int continuous;
}

#pragma mark - Override Methods

-(void) stateSymbolsWillVanish: (NSArray*)symbols
{
    self.isSymbolsOnVAFSing = YES;
    
    if (self.isChainVanishing) {
        [[EffectHelper getInstance] chainScoreWithEffect: symbols continuous:continuous];
    } else {
        [[EffectHelper getInstance] scoreWithEffect: symbols];
    }
}


#pragma mark - Public Methods

-(void) stateStartChainVanish
{
    // get symbols ...
    NSMutableArray* vanishSymbols = [SearchHelper searchMatchedInAllLines: MATCH_COUNT];
    
    
    // check if end chain vanish ~~~
    BOOL isContainsNull = [QueueViewsHelper isViewsInVisualAreaContains: [NSNull null]];
    if (vanishSymbols == nil && !isContainsNull) {
        
        // the first time check , no chain vanish , so should check vanishing~~~
        if (self.isChainVanishing) {
            [(ChainableEvent*)ACTION.currentEvent eventSymbolsDidChainVanish];
            self.isChainVanishing = NO;
            continuous = 0;
        }
        
        return;
    }
    
    if (vanishSymbols) {
        continuous++;
    }
    
    
    // then start , the vanish symbols maybe nil ~~~
    DLog(@"--- stateStartChainVanish");
    self.isChainVanishing = YES;
    [self.effect effectStartVanish: vanishSymbols];
}

@end

