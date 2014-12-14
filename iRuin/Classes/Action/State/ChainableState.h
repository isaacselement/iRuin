#import "BaseState.h"

@interface ChainableState : BaseState


@property (assign) BOOL isChainVanishing;


#pragma mark - Public Methods

-(void) stateStartChainVanish;



@end
