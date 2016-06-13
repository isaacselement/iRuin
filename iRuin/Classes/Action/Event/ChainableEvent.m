#import "ChainableEvent.h"
#import "AppInterface.h"

@implementation ChainableEvent
{
    BOOL isDisableChainable;
    BOOL isDisableFilterOnRollIn;
}


#pragma mark - Override Methods

-(void)eventInitialize
{
    [super eventInitialize];
    
    // so , default is NO !
    isDisableChainable = [DATA.config[@"isDisableChainable"] boolValue];
    isDisableFilterOnRollIn = [DATA.config[@"isDisableFilterOnRollIn"] boolValue];
}

-(void) eventSymbolsWillRollIn
{
    [super eventSymbolsWillRollIn];
    
    // do the filter match symbols job
    if (! isDisableFilterOnRollIn) {
        [FilterHelper forwardFilterMatchedObjects];
    }
}

-(void) eventSymbolsDidRollIn
{
    [super eventSymbolsDidRollIn];
    
    // chain vanish
    if (isDisableFilterOnRollIn) {
        [self startChainVainsh];
    }
}

-(void) eventSymbolsWillRollOut
{
    [super eventSymbolsWillRollOut];
    
    // Roll out when chain vanishing , should cancel the chain vanish
    [NSObject cancelPreviousPerformRequestsWithTarget:(ChainableState*)self.state selector:@selector(stateStartChainVanish) object:nil];
}


-(void) eventSymbolsDidAdjusts
{
    [super eventSymbolsDidAdjusts];
    
    [self startChainVainsh];
}

-(void) eventSymbolsDidFillIn
{
    [super eventSymbolsDidFillIn];

    [self startChainVainsh];
}

-(void) eventSymbolsDidSqueeze
{
    [super eventSymbolsDidSqueeze];
    
    [self startChainVainsh];
}




#pragma mark - Event Methods

-(void) eventSymbolsDidChainVanish
{
    DLOG(@"chaining done!~");
}






#pragma mark - 

-(void) startChainVainsh
{
    if (isDisableChainable) return;
    [NSObject cancelPreviousPerformRequestsWithTarget:(ChainableState*)self.state selector:@selector(stateStartChainVanish) object:nil];
    [(ChainableState*)self.state performSelector:@selector(stateStartChainVanish) withObject:nil afterDelay:0.2];
}


@end
