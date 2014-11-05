#import "GameEvent.h"
#import "AppInterface.h"


@implementation GameEvent

-(void) gameLaunch
{
    [ScheduledTask sharedInstance].timeInterval = 0.2;
    
//    [ScheduledTask.sharedInstance registerSchedule:self timeElapsed: 0.1 repeats:0];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_LAUNCH"]];
}


-(void) gameStart
{
    [[ScheduledTask sharedInstance] start];
    
    [ACTION.currentEffect effectStartRollIn];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_START"]];
}

-(void) gameBack
{
    [[ScheduledTask sharedInstance] pause];
    
    VIEW.gameView.pauseActionView.imageView.selected = NO;
    
    [ACTION.currentEffect effectStartRollOut];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_BACK"]];
}

-(void) gamePause
{
    [[ScheduledTask sharedInstance] pause];
}

-(void) gameResume
{
    [[ScheduledTask sharedInstance] start];
}

-(void) gameRefresh
{
    // for test now
    [ACTION.currentEffect performSelector:@selector(effectStartRollOut)];
    [ACTION.currentEffect performSelector:@selector(effectStartRollIn) withObject:nil afterDelay:2];
}

-(void) gameChat
{
    [[InAppIMNavgationController sharedInstance] showWithTilte:nil uniqueKey:nil];
}



//#pragma mark - Scheduled Action
//
//-(void) scheduledTask
//{
//    LineScrollView* lineScrollView = VIEW.gameView.headerView.lineScrollView;
//    CGPoint currentOffset = lineScrollView.contentOffset;
//    CGPoint offset = CGPointMake(currentOffset.x + 10, currentOffset.y);
//    [lineScrollView setContentOffset: offset animated:YES];
//}




@end

