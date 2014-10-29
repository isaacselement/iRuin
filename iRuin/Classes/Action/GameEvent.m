#import "GameEvent.h"
#import "AppInterface.h"


@implementation GameEvent


-(void) gameStartWithChapter: (int)chapterIndex
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
    
    [self designateActionTo:VIEW.controller config:DATA.config[@"GAME_In_ActionExecutors"]];
    
    [VIEW.controller switchToView: VIEW.gameView];
}

-(void) gameBack
{
    [ACTION.currentEffect effectStartRollOut];
    
    [self designateActionTo:VIEW.controller config:DATA.config[@"GAME_Out_ActionExecutors"]];
    
    [VIEW.controller switchToView: VIEW.chaptersView];
}

-(void) gamePause
{
    
}

-(void) gameRefresh
{
    
}

-(void) gameChat
{
    
    UIViewController* imController = [[UIViewController alloc] init];
    UINavigationController* imNavController = [[InAppIMNavgationController alloc] initWithRootViewController:imController];
    imNavController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    IAISimpleRoomInfo *roomInfo=[[IAISimpleRoomInfo alloc] init];
    [roomInfo setTitle:@"自定义聊天室-C"];
    [roomInfo setUniqueKey:@"cn.inappim.CustomRoom"];
    [InAppIMSDK enterCustomRoomClient:roomInfo navigationController:imController animated:YES];
    
    [VIEW.controller presentViewController:imNavController animated:YES completion:nil];
    
}


#pragma mark - Private Methods

#define kActionExecutors @"ActionExecutors"

-(void) designateActionTo: (id)object config:(NSDictionary*)config
{
    id actionsConfig = config[kActionExecutors];
    if (actionsConfig && [object isKindOfClass:[UIView class]]) {
        [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:@[object] values:nil baseTimes:nil];
    }
    
    for (NSString* key in config) {
        if ([key isEqualToString:kActionExecutors]) continue;
        
        NSObject* obj = [object valueForKey:key];
        NSDictionary* conf = config[key];
        [self designateActionTo: obj config:conf];
    }
}


@end

