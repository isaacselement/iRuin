#import "StateHelper.h"
#import "AppInterface.h"

@implementation StateHelper

+(NSMutableArray*) getViewsInContainer: (NSArray*)views
{
    NSMutableArray* results = [NSMutableArray array];
    [IterateHelper iterate: views handler:^BOOL(int index, id obj, int count) {
        if ([StateHelper isInContainer: obj]) {
            [results addObject: obj];
        }
        return NO;
    }];
    return results;
}

+(BOOL) isInContainer: (SymbolView*)symbol
{
    return [QueuePositionsHelper isPointInContainerRect: symbol.center rect:VIEW.gameView.containerView.bounds];
}




@end
