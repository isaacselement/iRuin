#import "GameEvent.h"
#import "AppInterface.h"

@implementation GameEvent

-(void) gameLaunch
{
    [ScheduledTask sharedInstance].timeInterval = 0.2;
    [[ScheduledTask sharedInstance] start];
    
    // chapter cells 
    // first time launch app, set the chapter index
    if (![APPStandUserDefaults objectForKey: User_LastTimeLaunch]) {
        [APPStandUserDefaults setObject:[NSDate date] forKey:User_FirstTimeLaunch];
        
        [APPStandUserDefaults setObject:DATA.config[@"ChaptersCountInFirstLaunch"] forKey:User_ChapterIndex];
        [ACTION.gameEffect designateToControllerWithConfig:DATA.config[@"GAME_INIT_LAUNCH"]];
    }
    [APPStandUserDefaults setObject:[NSDate date] forKey:User_LastTimeLaunch];
    
    LineScrollView* lineScrollView = VIEW.chaptersView.lineScrollView;
    [lineScrollView setCurrentIndex: [[APPStandUserDefaults objectForKey:User_ChapterIndex] intValue]];
    [lineScrollView setContentOffset: CGPointMake((lineScrollView.contentView.sizeWidth - lineScrollView.sizeWidth) / 2, 0) animated:NO];  // recenter the content view
    
    // chapters cells jump in effect
    [[EffectHelper getInstance] startChapterCellsEffect: DATA.config[@"Chapters_Cells_In_Game_Enter"]];
    
    // about background music
    if (![[APPStandUserDefaults objectForKey:@"isMusicDisable"] boolValue]) {
        [EventHelper playBackgroundMusic];
    }
    ((AudiosExecutor*)[VIEW.actionExecutorManager getActionExecutor:effect_AUDIO]).playFinishAction = ^(AudioHandler* handler) {
        NSString* audioURL = [handler.url absoluteString];
        if ([audioURL hasSuffix:@".mp3"]) {
            [EventHelper playNextBackgroundMusic];
        }
    };
    
    // about schedule task
    [[ScheduledHelper sharedInstance] registerScheduleTaskAccordingConfig];
}

-(void) gameStart
{
    ACTION.gameState.isGameStarted = YES;
    
    [[EffectHelper getInstance] startChapterCellsEffect: DATA.config[@"Chapters_Cells_In_Game_Start"]];
    
    [ACTION switchToMode: ACTION.gameState.currentMode chapter:ACTION.gameState.currentChapter];
    
    [ACTION.gameEffect designateToControllerWithConfig:DATA.config[@"GAME_START"]];
    
    [ACTION.modeEffect effectStartRollIn];
    
    int clearanceScore = [[ConfigHelper getUtilitiesConfig:@"ClearanceScoreBase"] intValue]  + RANDOM([[ConfigHelper getUtilitiesConfig:@"ClearanceScoreRandom"] intValue]);
    [[EffectHelper getInstance] showClearanceScore: clearanceScore];
    ACTION.gameState.clearanceScore = clearanceScore;
    
    [VIEW.gameView.timerView setTotalTime: VIEW.gameView.timerView.totalTime];
    
    ACTION.gameState.vanishAmount = 0;
    VIEW.gameView.vanishAmountLabel.number = 0;
}

-(void) gameReStart
{
    [self gameRefresh];
    
    int clearanceScore = [[ConfigHelper getUtilitiesConfig:@"ClearanceScoreBase"] intValue]  + RANDOM([[ConfigHelper getUtilitiesConfig:@"ClearanceScoreRandom"] intValue]);
    [[EffectHelper getInstance] showClearanceScore: clearanceScore];
    ACTION.gameState.clearanceScore = clearanceScore;
    
    [VIEW.gameView.timerView setTotalTime: VIEW.gameView.timerView.totalTime];
    
    ACTION.gameState.vanishAmount = 0;
    VIEW.gameView.vanishAmountLabel.number = 0;
}

-(void) gameBack
{
    ACTION.gameState.isGameStarted = NO;
    
    [DATA unsetModeChapterConfig];
    
    ACTION.gameState.vanishAmount = 0;
    VIEW.gameView.vanishAmountLabel.number = 0;
    
    [ACTION.modeEffect effectStartRollOut];
    
    [ACTION.gameEffect designateToControllerWithConfig:DATA.config[@"GAME_BACK"]];
    
    [[EffectHelper getInstance] startChapterCellsEffect: DATA.config[@"Chapters_Cells_In_Game_Back"]];
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
    [ACTION.modeEffect effectStartRollOut];
    double duration = [VIEW.actionDurations take];
    [ACTION.modeEffect performSelector:@selector(effectStartRollIn) withObject:nil afterDelay:duration];
}

@end

