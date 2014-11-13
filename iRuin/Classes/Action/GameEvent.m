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
    
    
    // chapter cells
    LineScrollView* chaptersCellViews = VIEW.chaptersView.lineScrollView;
    chaptersCellViews.lineScrollViewShouldShowIndex = ^BOOL(LineScrollView *lineScrollView, int index) {
        int userChapterIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:UserChapterIndex] intValue];
        return index <= userChapterIndex;
    };
    
    int userChapterIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:UserChapterIndex] intValue];
    int cellsCount = chaptersCellViews.contentView.subviews.count;
    DLOG(@"%d , %d", userChapterIndex, cellsCount);
    [chaptersCellViews setCurrentIndex: userChapterIndex - cellsCount];
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[ViewHelper getTopView] animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.dimBackground = YES;
    hud.detailsLabelText = @"Game is Over :-P";
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay: 3.5];
    
    
    float rate = 0;
    float userChapterIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:UserChapterIndex] floatValue];
    
    int score = VIEW.gameView.scoreLabel.number;
    int vanishCount = ACTION.gameState.vanishAmount;
    if (vanishCount != 0) {
        float rate = score / vanishCount;
        userChapterIndex += rate;
        [[NSUserDefaults standardUserDefaults] setObject: @(userChapterIndex) forKey:UserChapterIndex];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString* message = [NSString stringWithFormat:@"%.2f points up, season %d is ready for u :)", rate, (int)userChapterIndex];
        hud.detailsLabelText = message;
    });
    
    [self performSelector:@selector(gameBack) withObject:nil afterDelay: 1];
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

