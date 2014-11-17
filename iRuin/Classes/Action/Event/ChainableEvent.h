#import "BaseEvent.h"

@interface ChainableEvent : BaseEvent


@property (assign) BOOL isDisableChainable;



#pragma mark - Event Methods
-(void) eventSymbolsDidChainVanish;


@end
