#import "ChainableState.h"
#import "AppInterface.h"

@implementation ChainableState
{
    BOOL isDisableChainable;
    BOOL isDisableFilterOnRollIn;
    
    int startBonusChainingCount;
    int startAdjustChainingCount;
}

@synthesize isChainVanishing;
@synthesize isAdjustChaining;


#pragma mark - Override Methods

-(void) stateInitialize
{
    [super stateInitialize];
    
    // so , default is NO !
    isDisableChainable = [DATA.config[@"IsDisableChainable"] boolValue];
    isDisableFilterOnRollIn = [DATA.config[@"IsDisableFilterOnRollIn"] boolValue];
    
    startBonusChainingCount = [DATA.config[@"StartBonusChainingCount"] intValue];
    startAdjustChainingCount = [DATA.config[@"StartAdjustChainContinuous"] intValue];
}

-(void) stateSymbolsWillRollIn
{
    [super stateSymbolsWillRollIn];
    
    // do the filter match symbols job
    if (! isDisableFilterOnRollIn) {
        [FilterHelper forwardFilterMatchedObjects];
    }
}

-(void) stateSymbolsDidRollIn
{
    [super stateSymbolsDidRollIn];
    
    // chain vanish
    if (isDisableFilterOnRollIn) {
        [self startChainVainsh];
    }
}

-(void) stateSymbolsWillRollOut
{
    [super stateSymbolsWillRollOut];
    
    // Roll out when chain vanishing , should cancel the chain vanish
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stateStartChainVanish) object:nil];
}

-(void) stateStartVanishSymbols:(NSMutableArray *)vanishSymbols
{
    if (!self.isAdjustChaining) {
        if (ACTION.gameState.continuousCount >= startAdjustChainingCount) {
            self.isAdjustChaining = YES;
        }
    }
    
    [super stateStartVanishSymbols:vanishSymbols];
}

-(void) stateSymbolsDidAdjusts
{
    [super stateSymbolsDidAdjusts];
    
    [self startChainVainsh];
}

-(void) stateSymbolsDidFillIn
{
    [super stateSymbolsDidFillIn];
    
    [self startChainVainsh];
}

-(void) stateSymbolsDidSqueeze
{
    [super stateSymbolsDidSqueeze];
    
    [self startChainVainsh];
}


#pragma mark - Private Methods

-(void) stateSymbolsDidChainVanish
{
    DLOG(@"+++++++ DidChainVanish");
    [[EffectHelper getInstance] stopChainVanishingEffect];
}

-(void) startChainVainsh
{
    if (isDisableChainable) return;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stateStartChainVanish) object:nil];
    [self performSelector:@selector(stateStartChainVanish) withObject:nil afterDelay:0.2];
}

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
                [self stateSymbolsDidChainVanish];
                isChainVanishing = NO;
                ACTION.gameState.continuousCount = 0;
            }
            
            isAdjustChaining = NO;

        } else {
            [self.effect effectStartAdjustFillSqueeze:nil vanishDuration:0];
        }
        
    } else {
        
        // then start , the vanish symbols maybe nil ~~~
        // in effectStartVanish: , if nil , then return
        // if you want no vanish and start adjust or fill , just call their method directly
        
        isChainVanishing = YES;
        
        // bonus effect
        ACTION.gameState.continuousCount++;
        [ACTION.gameState startBonusEffect: ACTION.gameState.continuousCount];

        DLOG(@"+++++++ Chaining: %d", ACTION.gameState.continuousCount);
        [[EffectHelper getInstance] startChainVanishingEffect: vanishSymbols];
        
        // ----- start vanish
        [self stateStartVanishSymbols: vanishSymbols];
        
        
    }
}

@end