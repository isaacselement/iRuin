#import "ChainableEvent.h"
#import "AppInterface.h"

@implementation ChainableEvent

#pragma mark - Override Methods
-(void) eventSymbolsWillRollIn
{
    [super eventSymbolsWillRollIn];
    
    // do the filter match symbols job
    [FilterHelper forwardFilterMatchedObjects];
}



-(void) eventSymbolsDidAdjusts
{
    [super eventSymbolsDidAdjusts];
    
    [(ChainableState*)self.state stateStartChaineVanish];
}

-(void) eventSymbolsDidFillIn
{
    [super eventSymbolsDidFillIn];
    
    [(ChainableState*)self.state stateStartChaineVanish];
}

-(void) eventSymbolsDidSqueeze
{
    [super eventSymbolsDidSqueeze];
    
    [(ChainableState*)self.state stateStartChaineVanish];
}


#pragma mark - Event Methods
-(void) didChainVanish
{
    DLog(@"didChainVanish");
}

@end
