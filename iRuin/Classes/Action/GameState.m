#import "GameState.h"
#import "AppInterface.h"

@implementation GameState


- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}



-(NSString*) oneRandomSymbolName
{
    NSArray* keys = [DATA.config[@"SYMBOLS"] allKeys];
    int index = arc4random() % keys.count;
    NSString* name = [keys objectAtIndex: index];
    return name;
}

@end
