#import "GameState.h"
#import "AppInterface.h"

@implementation GameState


@synthesize prototypes;

- (instancetype)init
{
    self = [super init];
    if (self) {
        prototypes = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) initializePrototypes
{
    NSDictionary* specifications = DATA.config[@"SYMBOLS"];
    for (NSString* name in specifications) {
        Symbol* prototype = [[Symbol alloc] initWithName:name definition:specifications[name]];
        [prototypes addObject: prototype];
    }
}

-(Symbol*) oneRandomPrototype
{
    return [prototypes objectAtIndex: arc4random() % prototypes.count];
}

@end
