#import "BaseState.h"

@interface ChainableState : BaseState

@property (assign) BOOL isChainVanishing;

@property (assign) BOOL isFullAdjusting;

// continuously chain vanish number
@property (assign) int continuous;


#pragma mark - Public Methods

-(void) stateStartChainVanish;

@end
