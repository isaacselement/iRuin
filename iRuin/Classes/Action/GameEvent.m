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
    
    
    // chapters cells jumb in effect
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
    
    [ACTION switchToMode: ACTION.gameState.currentMode chapter:ACTION.gameState.currentChapter];
    
    [ACTION.currentEffect effectStartRollIn];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_START"]];
    
    // chapters cells effect
    [self chaptersValuesActions: DATA.config[@"Chapters_Cells_In_Game_Start"]];
    
    // show hint
    int clearanceScore = [[ConfigHelper getUtilitiesConfig:@"ClearanceScoreBase"] intValue]  + RANDOM([[ConfigHelper getUtilitiesConfig:@"ClearanceScoreRandom"] intValue]);
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
    
    [ACTION.currentEffect effectStartRollOut];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_BACK"]];
    
    // chapters cells effect
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
        NSDictionary* config = [ConfigHelper getNodeConfig:cellsConfigs key:indexKey];
        [ACTION.gameEffect designateValuesActionsTo:cell config: config];
    }
}



@end

