#import "GameEvent.h"
#import "AppInterface.h"


@implementation GameEvent


-(void) gameLaunch
{
    [ScheduledTask sharedInstance].timeInterval = 0.2;
    
    
    
    //
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_LAUNCH"]];
    
    // chapters cells effect
    [self chaptersValuesActions: DATA.config[@"GAME_LAUNCH_Chapters_Cells"]];
    
    
    [VIEW.chaptersView.lineScrollView setCurrentIndex: [[[NSUserDefaults standardUserDefaults] objectForKey:UserChapterIndex] intValue]];
}




-(void) gameStart
{
    [[ScheduledTask sharedInstance] start];
    
    
    
    //
    [ACTION.currentEffect effectStartRollIn];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_START"]];
    
    // chapters cells effect
    [self chaptersValuesActions: DATA.config[@"GAME_START_Chapters_Cells"]];
}

-(void) gameBack
{
    [[ScheduledTask sharedInstance] pause];
    
    
    
    //
    VIEW.gameView.pauseActionView.imageView.selected = NO;
    
    [ACTION.currentEffect effectStartRollOut];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_BACK"]];
    
    // chapters cells effect
    [self chaptersValuesActions: DATA.config[@"GAME_BACK_Chapters_Cells"]];
    
    
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:UserChapterIndex] intValue] > VIEW.chaptersView.lineScrollView.currentIndex) {
//        [VIEW.chaptersView.lineScrollView setCurrentIndex: [[[NSUserDefaults standardUserDefaults] objectForKey:UserChapterIndex] intValue]];
//    }
}






-(void) gamePause
{
    [[ScheduledTask sharedInstance] pause];
}

-(void) gameResume
{
    [[ScheduledTask sharedInstance] start];
}

-(void) gameOver
{
    int score = VIEW.gameView.scoreLabel.number;
    int vanishCount = ACTION.gameState.vanishAmount;
    
    if (vanishCount == 0) return;
    
    float rate = score / vanishCount;
    
    DLOG(@"%.2f", rate);
    
    float index = [[[NSUserDefaults standardUserDefaults] objectForKey:UserChapterIndex] floatValue];
    index += rate;
    
    [[NSUserDefaults standardUserDefaults] setObject: @(index) forKey:UserChapterIndex];
    
    
    
    [self gameBack];
}

-(void) gameRefresh
{
    BaseEffect* effect = ACTION.currentEffect;
    [VIEW.actionDurations clear];
    [effect effectStartRollOut];
    double duration = [VIEW.actionDurations take];
    [effect performSelector:@selector(effectStartRollIn) withObject:nil afterDelay:duration];
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

