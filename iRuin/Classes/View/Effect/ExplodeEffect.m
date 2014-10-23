#import "ExplodeEffect.h"
#import "AppInterface.h"

@implementation ExplodeEffect


-(void)effectStartVanish:(NSMutableArray *)symbols
{
    [super effectStartVanish:symbols];
    
    // override it 
//    [NSObject cancelPreviousPerformRequestsWithTarget:self.event selector:@selector(eventSymbolsDidVanish:) object:symbols];
//    [self.event performSelector: @selector(eventSymbolsDidVanish:) withObject:symbols afterDelay:0.5];
}


@end
