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
    
    [VIEW.chaptersView.lineScrollView setCurrentIndex: [[StandUserDefaults objectForKey:User_ChapterIndex] intValue]];
    VIEW.chaptersView.lineScrollView.lineScrollViewShouldShowIndex = ^BOOL(LineScrollView *lineScrollView, int index) {
        int minimalIndex = NSIntegerMin;
        if (DATA.config[@"Utilities"][@"ChaptersMinimalIndex"]) {
            minimalIndex = [DATA.config[@"Utilities"][@"ChaptersMinimalIndex"] intValue];
        }
        return index >= minimalIndex && index <= [[StandUserDefaults objectForKey:User_ChapterIndex] intValue];
    };
    
    
    // chapters cells jumb in effect
    [self chaptersValuesActions: DATA.config[@"GAME_LAUNCH_Chapters_Cells"]];
    
    
    // about mute music
    [VIEW.actionExecutorManager runActionExecutors:DATA.config[@"PlayActions"] onObjects:@[@""] values:nil baseTimes:nil];
    
    
    // about schedule task
    [[ScheduledHelper sharedInstance] registerScheduleTaskAccordingConfig];
}




-(void) gameStart
{
    [ACTION switchToMode: ACTION.gameState.currentMode chapter:ACTION.gameState.currentChapter];
    
    //
    [ACTION.currentEffect effectStartRollIn];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:DATA.config[@"GAME_START"]];
    
    // chapters cells effect
    [self chaptersValuesActions: DATA.config[@"GAME_START_Chapters_Cells"]];
}

-(void) gameBack
{
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[ViewHelper getTopView] animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.dimBackground = YES;
    hud.labelText = @"Game is Over :-P";
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay: 6];
    
    
    float rate = 0;
    float userChapterIndex = [[StandUserDefaults objectForKey:User_ChapterIndex] floatValue];
    
    int score = VIEW.gameView.scoreLabel.number;
    int vanishCount = ACTION.gameState.vanishAmount;
    if (vanishCount != 0) {
        rate = (float)score / vanishCount;
        userChapterIndex += rate;
        [StandUserDefaults setObject: @(userChapterIndex) forKey:User_ChapterIndex];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString* message = [NSString stringWithFormat:@" %d (score) ÷ %d (vanish count) = %.2f", score, vanishCount, rate];
        hud.detailsLabelText = message;
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString* message = [NSString stringWithFormat:@"Season %d is unlocked :)", (int)userChapterIndex];
        hud.labelText = message;
        hud.detailsLabelText = nil;
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
    NSString* title = VIEW.gameView.seasonLabel.text;
    NSString* uniqueKey = [NSString stringWithFormat:@"%@.%d",IRuin_Bundle_ID, ACTION.gameState.currentChapter];
    [[InAppIMNavgationController sharedInstance] showWithTilte:title uniqueKey:uniqueKey];
}



#pragma mark -

-(void) chaptersValuesActions: (NSDictionary*)cellsConfigs
{
    NSArray* chaptersCells = VIEW.chaptersView.lineScrollView.contentView.subviews;
    for (int i = 0 ; i < chaptersCells.count; i++) {
        ImageLabelLineScrollCell* cell = [chaptersCells objectAtIndex:i];
        
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

