#import "GameEvent.h"
#import "AppInterface.h"



@implementation GameEvent


-(void) launchGame
{
    [ScheduledTask sharedInstance].timeInterval = 0.2;
    [[ScheduledTask sharedInstance] start];
    
    
    // chapter cells 
    // first time launch app, set the chapter index
    if (![StandUserDefaults objectForKey: User_LastTimeLaunch]) {
        [StandUserDefaults setObject:DATA.config[@"Utilities"][@"FirstTimeLaunchGiveChaptersCount"] forKey:User_ChapterIndex];
    }
    [StandUserDefaults setObject:[NSDate date] forKey:User_LastTimeLaunch];
    
    LineScrollView* lineScrollView = VIEW.chaptersView.lineScrollView;
    [lineScrollView setCurrentIndex: [[StandUserDefaults objectForKey:User_ChapterIndex] intValue]];
    
    lineScrollView.lineScrollViewShouldShowIndex = ^BOOL(LineScrollView *lineScrollViewObj, int index) {
        NSInteger minimalIndex = NSIntegerMin;
        if (DATA.config[@"Utilities"][@"ChaptersMinimalIndex"]) {
            minimalIndex = [DATA.config[@"Utilities"][@"ChaptersMinimalIndex"] intValue];
        }
        return index >= minimalIndex && index <= [[StandUserDefaults objectForKey:User_ChapterIndex] intValue];
    };
    [lineScrollView setContentOffset: CGPointMake(lineScrollView.contentView.sizeWidth - lineScrollView.sizeWidth, 0) animated:NO];
    
    
    // chapters cells jumb in effect
    [self chaptersValuesActions: DATA.config[@"GAME_LAUNCH_Chapters_Cells"]];
    
    
    // about mute music
    [VIEW.actionExecutorManager runActionExecutors:DATA.config[@"PlayActions"] onObjects:@[@""] values:nil baseTimes:nil];
    
    
    // about schedule task
    [[ScheduledHelper sharedInstance] registerScheduleTaskAccordingConfig];
}




-(void) gameStart
{
    ACTION.gameState.isGameStarted = YES;
    
    [ACTION switchToMode: ACTION.gameState.currentMode chapter:ACTION.gameState.currentChapter];
    
    //
    [ACTION.currentEffect effectStartRollIn];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_START"]];
    
    // chapters cells effect
    [self chaptersValuesActions: DATA.config[@"GAME_START_Chapters_Cells"]];
    
    
    
    
    // show hint
    int clearanceScore = [DATA.config[@"Utilities"][@"ClearanceScoreBase"] intValue]  + RANDOM([DATA.config[@"Utilities"][@"ClearanceScoreRandom"] intValue]);
    if (clearanceScore == 0) {
        clearanceScore = RANDOM(1000);
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[ViewHelper getTopView] animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = [NSString stringWithFormat: @"This Season Clearance Score is %d", clearanceScore];
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay: 1 + RANDOM(3)];
    
    ACTION.gameState.clearanceScore = clearanceScore;
}

-(void) gameBack
{
    ACTION.gameState.isGameStarted = NO;
    
    [DATA unsetModeChapterConfig];
    
    ACTION.gameState.vanishAmount = 0;
    
    //
    VIEW.gameView.pauseActionView.imageView.selected = NO;
    
    [ACTION.currentEffect effectStartRollOut];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_BACK"]];
    
    // chapters cells effect
    [self chaptersValuesActions: DATA.config[@"GAME_BACK_Chapters_Cells"]];
}




-(void) gamePause
{
    VIEW.gameView.containerView.userInteractionEnabled = NO;
}

-(void) gameResume
{
    VIEW.gameView.containerView.userInteractionEnabled = YES;
}

-(void) gameOver
{
    [[EffectHelper getInstance] showPassedSeasonHint:6 title:@"Game Over" scoreDelay:1 messageDelay:3.5];
    
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



#pragma mark -

-(void) chaptersValuesActions: (NSDictionary*)cellsConfigs
{
    NSArray* chaptersCells = VIEW.chaptersView.lineScrollView.contentView.subviews;
    for (int i = 0 ; i < chaptersCells.count; i++) {
        ImageLabelLineScrollCell* cell = [chaptersCells objectAtIndex:i];
        NSString* indexKey = [NSString stringWithFormat:@"%d", i];
        NSDictionary* config = [ConfigHelper handleDefaultCommonConfig:cellsConfigs key:indexKey];
        [ACTION.gameEffect designateValuesActionsTo:cell config: config];
    }
}



@end

