#import "ChainableState.h"
#import "AppInterface.h"

@implementation ChainableState

@synthesize isChainVanishing;
@synthesize isAutoAdjusting;

@synthesize continuous;

#pragma mark - Public Methods

-(void) stateStartChainVanish
{
    // get symbols ...
    NSMutableArray* vanishSymbols = [SearchHelper searchMatchedInAllLines: MATCH_COUNT];
    
    // check if end chain vanish ~~~
    if (vanishSymbols == nil) {
        
        BOOL isContainsBlank = [QueueViewsHelper isViewsInVisualAreaContains: [NSNull null]];
        if (isContainsBlank == NO) {
            
            // the first time check , no chain vanish , so should check vanishing~~~
            if (isChainVanishing) {
                [(ChainableEvent*)ACTION.modeEvent eventSymbolsDidChainVanish];
                isChainVanishing = NO;
                continuous = 0;
            }

        } else {
            
        }
        
    } else {
        
        // then start , the vanish symbols maybe nil ~~~
        // in effectStartVanish: , if nil , then return
        // if you want no vanish and start adjust or fill , just call their method directly
        
        DLOG(@"--- stateStartChainVanish");
        isChainVanishing = YES;
        isAutoAdjusting = YES;
        [self stateStartVanishSymbols: vanishSymbols];
        
        continuous++;
        [[EffectHelper getInstance] startChainScoreEffect: vanishSymbols continuous:continuous];
    }
}

@end

