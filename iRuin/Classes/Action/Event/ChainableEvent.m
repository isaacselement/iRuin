#import "ChainableEvent.h"
#import "AppInterface.h"

@implementation ChainableEvent

#pragma mark - Override Methods

-(void)eventInitialize
{
    [super eventInitialize];
    
    self.isDisableChainable = [DATA.config[@"isDisableChainable"] boolValue];
}

-(void) eventSymbolsWillRollIn
{
    [super eventSymbolsWillRollIn];
    
    // do the filter match symbols job
    if (!self.isDisableChainable) {
        [FilterHelper forwardFilterMatchedObjects];
    }
}


-(void) eventSymbolsDidAdjusts
{
    [super eventSymbolsDidAdjusts];
    
//    if (!self.isDisableChainable) {
//        [(ChainableState*)self.state stateStartChaineVanish];
//    }
}

-(void) eventSymbolsDidFillIn
{
    [super eventSymbolsDidFillIn];
    
//    if (!self.isDisableChainable) {
//        [(ChainableState*)self.state stateStartChaineVanish];
//    }
}

-(void) eventSymbolsDidSqueeze
{
    [super eventSymbolsDidSqueeze];
    
//    if (!self.isDisableChainable) {
//        [(ChainableState*)self.state stateStartChaineVanish];
//    }
}


#pragma mark - Event Methods
-(void) didChainVanish
{
    DLog(@"didChainVanish");
}

@end
