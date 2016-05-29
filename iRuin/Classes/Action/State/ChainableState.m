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
    [super stateSymbolsWillVanish:symbols];
    
    if (self.isChainVanishing) {
        continuous++;
        [[EffectHelper getInstance] chainScoreWithEffect: symbols continuous:continuous];
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
    
    // then start , the vanish symbols maybe nil ~~~
    // in effectStartVanish: , if nil , then return
    // if you want no vanish and start adjust or fill , just call their method directly
    DLOG(@"--- stateStartChainVanish");
    self.isChainVanishing = YES;
    [self.effect effectStartVanish: vanishSymbols];
}

@end

