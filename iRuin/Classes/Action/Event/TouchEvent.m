#import "TouchEvent.h"
#import "AppInterface.h"

@implementation TouchEvent

-(void) eventSymbolsWillVanish: (NSArray*)symbols
{
    [super eventSymbolsWillVanish:symbols];
    
    
    // TODO: TEMP CODE HERE ------------------------------
    int bonusCount = symbols.count - MATCH_COUNT;
    
    if (bonusCount > 0) {
        
        int bonusScore = bonusCount * 2;
        [[EffectHelper getInstance] bonusEffectWithScore:bonusScore];
        
    }
}


@end
