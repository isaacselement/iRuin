#import "BaseState.h"

@interface ChainableState : BaseState


@property (assign) BOOL isChainVanishing;

// continuously chain vanish number
@property (assign) int continuous;


#pragma mark - Public Methods

-(void) stateStartChainVanish;

@end
