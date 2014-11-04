#import "GameState.h"
#import "AppInterface.h"

@implementation GameState


@synthesize orientation;

@synthesize isGameStarted;

@synthesize isSymbolsOnMovement;

@synthesize currentChapter;

@synthesize vanishAmount;




- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


@end
