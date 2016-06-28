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
    [ACTION.modeEffect effectStartRollIn];
    
    [VIEW.gameView.timerView setTotalTime: VIEW.gameView.timerView.totalTime];
    
    [ACTION.gameState resetStatus];
}

-(void) gameReStart
{
    [VIEW.actionDurations clear];
    [ACTION.modeEffect effectStartRollOut];
    double duration = [VIEW.actionDurations take];
    [self performSelector:@selector(gameStart) withObject:nil afterDelay:duration];
}

-(void) gameBack
{
    [ACTION.gameState resetStatus];
    
    [DATA unsetChapterModeConfig];
    
    [ACTION.modeEffect effectStartRollOut];
    
    [ACTION.gameEffect designateToControllerWithConfig:DATA.config[@"GAME_BACK"]];
    
    [[EffectHelper getInstance] startChapterCellsEffect: DATA.config[@"Chapters_Cells_In_Game_Back"]];
}

-(void) gameOver
{
    if (ACTION.modeState.isSymbolsOnVAFSing || ([ACTION.modeState isKindOfClass:[ChainableState class]] && ((ChainableState*)ACTION.modeState).isChainVanishing)) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(gameOver) object:nil];
        [self performSelector:@selector(gameOver) withObject:nil afterDelay:0.5];
    } else {
        [self gameBack];
    }
}

@end

