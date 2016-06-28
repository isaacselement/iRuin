#import "ScoreHelper.h"
#import "AppInterface.h"

@implementation ScoreHelper
{
    BOOL isPassedOneSeason;
}

@synthesize clearedContinuous;
@synthesize clearedVanishedCount;
@synthesize clearedVanishedViewCount;

+(ScoreHelper*) getInstance
{
    static ScoreHelper* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ScoreHelper alloc] init];
    });
    return instance;
}

-(void) setupClearedSeasonStatus
{
    isPassedOneSeason = NO;
    
    clearedContinuous = 0;
    clearedVanishedCount = 0;
    clearedVanishedViewCount = 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary* conditionConfig = [ConfigHelper getLoopConfig:DATA.config[@"WIN_LOSE_CONDITION"] index:ACTION.gameState.currentChapter];
        [ACTION.gameEffect designateValuesActionsTo:self config:conditionConfig];
        
        NSDictionary* effectConfig = [ConfigHelper getLoopConfig:DATA.config[@"WIN_LOSE_PROMPT"] index:ACTION.gameState.currentChapter];
        [ACTION.gameEffect designateToControllerWithConfig:effectConfig];
    });
    
}

-(void) checkIsClearedSeasonOnSymbolVanish
{
    if (isPassedOneSeason) return;
    
    BOOL isPassed = [self isCleared];

    if (isPassed) {
        isPassedOneSeason = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [APPStandUserDefaults setObject: @(ACTION.gameState.currentChapter + 1) forKey:User_ChapterIndex];
            [VIEW.chaptersView.lineScrollView setCurrentIndex: [[APPStandUserDefaults objectForKey:User_ChapterIndex] intValue]];
            
            [ACTION.gameEffect designateToControllerWithConfig:DATA.config[@"WIN"]];
            [ACTION.gameEvent gameOver];
        });
    }
}

-(void) checkIsClearedSeasonOnTimesOut
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ACTION.gameEffect designateToControllerWithConfig:DATA.config[@"LOSE"]];
        [ACTION.gameEvent gameOver];
    });
}

-(BOOL) isCleared
{
    BOOL isPassed = YES;
    
    if (clearedContinuous != 0) {
        isPassed &= ((ChainableState*)ACTION.modeState).continuous >= clearedContinuous;
    }
    
    if (clearedVanishedCount != 0) {
        isPassed &= ACTION.gameState.vanishCount >= clearedVanishedCount;
    }
    
    if (clearedVanishedViewCount != 0) {
        isPassed &= ACTION.gameState.vanishViewsAmount >= clearedVanishedViewCount;
    }
    return isPassed;
}

@end
