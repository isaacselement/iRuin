#import "BaseState.h"

@interface ChainableState : BaseState


#pragma mark - Public Methods

-(void) stateStartChaineVanish;



#pragma mark - SubClass Override Methods

-(NSMutableArray*) getChaineVanishSymbols;


@end
