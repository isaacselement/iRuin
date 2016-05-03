#import "GameEvent.h"
#import "AppInterface.h"

@implementation GameEvent

-(void) launchGame
{
    [ScheduledTask sharedInstance].timeInterval = 0.2;
    [[ScheduledTask sharedInstance] start];
    
    // chapter cells 
    // first time launch app, set the chapter index
    if (![APPStandUserDefaults objectForKey: User_LastTimeLaunch]) {
        [APPStandUserDefaults setObject:[ConfigHelper getUtilitiesConfig:@"FirstTimeLaunchGiveChaptersCount"] forKey:User_ChapterIndex];
    }
    [APPStandUserDefaults setObject:[NSDate date] forKey:User_LastTimeLaunch];
    
    LineScrollView* lineScrollView = VIEW.chaptersView.lineScrollView;
    [lineScrollView setCurrentIndex: [[APPStandUserDefaults objectForKey:User_ChapterIndex] intValue]];
    
    lineScrollView.lineScrollViewShouldShowIndex = ^BOOL(LineScrollView *lineScrollViewObj, int index) {
        NSInteger minimalIndex = NSIntegerMin;
        if ([ConfigHelper getUtilitiesConfig:@"ChaptersMinimalIndex"]) {
            minimalIndex = [[ConfigHelper getUtilitiesConfig:@"ChaptersMinimalIndex"] intValue];
        }
        return index >= minimalIndex && index <= [[APPStandUserDefaults objectForKey:User_ChapterIndex] intValue];
    };
    [lineScrollView setContentOffset: CGPointMake(lineScrollView.contentView.sizeWidth - lineScrollView.sizeWidth, 0) animated:NO];
    
    
    // chapters cells jump in effect
    [self chaptersValuesActions: DATA.config[@"Chapters_Cells_In_Game_Enter"]];
    
    // about background music
    if (![[APPStandUserDefaults objectForKey:@"isMusicDisable"] boolValue]) {
        [VIEW.actionExecutorManager runAudioActionExecutors:[ConfigHelper getMusicConfig:@"PlayActions"]];
    }
    
    // about schedule task
    [[ScheduledHelper sharedInstance] registerScheduleTaskAccordingConfig];
}

-(void) gameStart
{
    ACTION.gameState.isGameStarted = YES;
    
    [self chaptersValuesActions: DATA.config[@"Chapters_Cells_In_Game_Start"]];
    
    [ACTION switchToMode: ACTION.gameState.currentMode chapter:ACTION.gameState.currentChapter];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_START"]];
    
    [ACTION.currentEffect effectStartRollIn];
    
    [self showClearanceScoreAndSetTimer];
    
    ACTION.gameState.vanishAmount = 0;
    VIEW.gameView.scoreLabel.number = 0;
}

-(void) gameReStart
{
    [self gameRefresh];
    
    [self showClearanceScoreAndSetTimer];
    
    ACTION.gameState.vanishAmount = 0;
    VIEW.gameView.scoreLabel.number = 0;
}

-(void) gameBack
{
    ACTION.gameState.isGameStarted = NO;
    
    [DATA unsetModeChapterConfig];
    
    ACTION.gameState.vanishAmount = 0;
    VIEW.gameView.scoreLabel.number = 0;
    
    [ACTION.currentEffect effectStartRollOut];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_BACK"]];
    
    [self chaptersValuesActions: DATA.config[@"Chapters_Cells_In_Game_Back"]];
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
    [VIEW.actionDurations clear];
    [ACTION.currentEffect effectStartRollOut];
    double duration = [VIEW.actionDurations take];
    [ACTION.currentEffect performSelector:@selector(effectStartRollIn) withObject:nil afterDelay:duration];
}

#pragma mark -

-(void) chaptersValuesActions: (NSDictionary*)cellsConfigs
{
    NSArray* chaptersCells = VIEW.chaptersView.lineScrollView.contentView.subviews;
    for (int i = 0 ; i < chaptersCells.count; i++) {
        ImageLabelLineScrollCell* cell = [chaptersCells objectAtIndex:i];
        NSString* indexKey = [NSString stringWithFormat:@"%d", i];
        NSDictionary* config = [ConfigHelper getNodeConfig:cellsConfigs key:indexKey];
        [ACTION.gameEffect designateValuesActionsTo:cell config: config];
    }
}

-(void) showClearanceScoreAndSetTimer
{
    int clearanceScore = [[ConfigHelper getUtilitiesConfig:@"ClearanceScoreBase"] intValue]  + RANDOM([[ConfigHelper getUtilitiesConfig:@"ClearanceScoreRandom"] intValue]);
    [[EffectHelper getInstance] showClearanceScore: clearanceScore];
    ACTION.gameState.clearanceScore = clearanceScore;
    [VIEW.gameView.timerView setTotalTime: VIEW.gameView.timerView.totalTime];
}


@end

