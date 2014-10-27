#import "GameEvent.h"
#import "AppInterface.h"


@implementation GameEvent


-(void) gameBack
{
    [ACTION.currentEffect effectStartRollOut];
    
    GameView* gameView = VIEW.gameView;
    NSDictionary* gameViewsActionsConfigs = DATA.config[@"GAMEVIEWS_Back_ActionExecutors"];
    
    for (NSString* key in gameViewsActionsConfigs) {
        UIView* view = nil;
        if ([key isEqualToString:@"SELF"]) {
            view = gameView;
        } else {
            view = [gameView valueForKey: key];
        }
        NSArray* actionsConfig = gameViewsActionsConfigs[key];
        [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:@[view] values:nil baseTimes:nil];
    }
    
}

-(void) gamePause
{
    
}

-(void) gameRefresh
{
    
}


@end

