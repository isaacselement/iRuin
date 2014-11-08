#import "GameEvent.h"
#import "AppInterface.h"


@implementation GameEvent


-(void) gameLaunch
{
    [ScheduledTask sharedInstance].timeInterval = 0.2;
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_LAUNCH"]];
    
    // chapters cells effect
    [self chaptersValuesActions: DATA.config[@"GAME_LAUNCH_Chapters_Cells"]];
}




-(void) gameStart
{
    [[ScheduledTask sharedInstance] start];
    
    [ACTION.currentEffect effectStartRollIn];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_START"]];
    
    // chapters cells effect
    [self chaptersValuesActions: DATA.config[@"GAME_START_Chapters_Cells"]];
}

-(void) gameBack
{
    [[ScheduledTask sharedInstance] pause];
    
    VIEW.gameView.pauseActionView.imageView.selected = NO;
    
    [ACTION.currentEffect effectStartRollOut];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_BACK"]];
    
    // chapters cells effect
    [self chaptersValuesActions: DATA.config[@"GAME_BACK_Chapters_Cells"]];
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
    [ACTION.currentEffect performSelector:@selector(effectStartRollOut)];
    [ACTION.currentEffect performSelector:@selector(effectStartRollIn) withObject:nil afterDelay:2];
}





-(void) gameChat
{
    [[InAppIMNavgationController sharedInstance] showWithTilte:nil uniqueKey:nil];
}



#pragma mark -

-(void) chaptersValuesActions: (NSDictionary*)cellsConfigs
{
    NSArray* chaptersCells = VIEW.chaptersView.lineScrollView.contentView.subviews;
    for (int i = 0 ; i < chaptersCells.count; i++) {
        ImageLabelLineScrollCell* cell = [chaptersCells objectAtIndex:i];
        
        // restore the status
        [cell.layer removeAllAnimations];
        
        // values and actions
        NSString* iKey = [NSString stringWithFormat:@"%d", i];
        NSDictionary* config = cellsConfigs[iKey];
        if (! config) {
            config = cellsConfigs[@"default"];
        }
        if (cellsConfigs[@"common"]) {
            config = [DictionaryHelper combines:cellsConfigs[@"common"] with:config];
        }
        
        [ACTION.gameEffect designateValuesActionsTo:cell config: config];
    }
}


@end

