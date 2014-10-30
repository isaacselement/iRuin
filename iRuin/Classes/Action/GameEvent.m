#import "GameEvent.h"
#import "AppInterface.h"


@implementation GameEvent

-(void) gameLaunch
{
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_Launch_ActionExecutors"]];
}


-(void) gameStart
{
    [ACTION.currentEffect effectStartRollIn];
    
    // for the no roll in symbols ...
    [IterateHelper iterateTwoDimensionArray:QueueViewsHelper.viewsRepository handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
        SymbolView* symbolView = (SymbolView*)obj;
        CGRect rect = [QueuePositionsHelper.rectsRepository[outterIndex][innerIndex] CGRectValue];
        
        if (!CGRectEqualToRect(rect, symbolView.frame)) {
            symbolView.frame = rect;
        }

        return NO;
    }];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_Start_ActionExecutors"]];
}

-(void) gameBack
{
    [ACTION.currentEffect effectStartRollOut];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_Back_ActionExecutors"]];
}

-(void) gamePause
{
    
}

-(void) gameRefresh
{
    
}

-(void) gameChat
{
    [[InAppIMNavgationController sharedInstance] showWithTilte:nil uniqueKey:nil];;
}




@end

