#import "EffectHelper.h"
#import "AppInterface.h"


#define SeasonHintHudTag 2008


@implementation EffectHelper
{
    // queue views positions handler
    ViewsInRepositoryPositionsHandler fillInViewsPositionsHandler;
    ViewsInRepositoryPositionsHandler adjustViewsInVisualPositionsHandler;
    ViewsInRepositoryPositionsHandler rollInViewsInRepositoryPositionsHandler;
    ViewsInRepositoryPositionsHandler rollOutViewsInRepositoryPositionsHandler;
}


static EffectHelper* oneInstance = nil;

+(EffectHelper*) getInstance
{
    if (!oneInstance) {
        oneInstance = [[EffectHelper alloc] init];
    }
    return oneInstance;
}


#pragma mark - Queue Views Positiosn Handler

-(ViewsInRepositoryPositionsHandler) fillInViewsPositionsHandler
{
    if (! fillInViewsPositionsHandler) {
        fillInViewsPositionsHandler = ^NSArray *(NSArray *lines, NSArray *indexPaths, NSArray* groupedNullIndexpaths, NSDictionary *linesConfig, NSArray* vanishingViews) {
            
            // TODO: If not enough ~~~~~~ , cause may vanish many ~~~~~  !
            NSMutableArray* uselessViews = [QueueViewsHelper getUselessViews];
            for (UIView* symbol in vanishingViews) {
                [uselessViews removeObject: symbol];
            }
            
            int count = 0 ;
            NSMutableArray* views = [NSMutableArray array];
            for (NSUInteger i = 0; i < groupedNullIndexpaths.count; i++) {
                NSArray* oneGroupedNullIndexpaths = groupedNullIndexpaths[i];
                NSMutableArray* innerViews = [NSMutableArray array];
                for (NSUInteger j = 0; j < oneGroupedNullIndexpaths.count; j++) {
                    SymbolView* symbol = [uselessViews objectAtIndex:count];
                    [symbol restore];
                    symbol.identification = [SymbolView getOneRandomSymbolIdentification];
                    [innerViews addObject: symbol];
                    count++;
                }
                [views addObject: innerViews];
            }
            
            NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
            
            // cause roll know how many view roll in , fill in need dynamic
            for (int i = 0; i < views.count; i++) {
                NSMutableArray* innverViews = [views objectAtIndex: i];
                for (int j = 1; j < innverViews.count; j++) {
                    [positions[i] insertObject:positions[i][0] atIndex:0];
                }
            }
            return @[views, positions];
        };
    }
    return fillInViewsPositionsHandler;
}

-(ViewsInRepositoryPositionsHandler) adjustViewsInVisualPositionsHandler
{
    if (! adjustViewsInVisualPositionsHandler) {
        adjustViewsInVisualPositionsHandler = ^NSArray *(NSArray *lines, NSArray *indexPaths, NSArray* groupedNullIndexpaths, NSDictionary *linesConfig, NSArray* vanishingViews) {
            NSMutableArray* views = [QueueViewsHelper getViewsQueuesIn:QueueViewsHelper.viewsInVisualArea lines:lines indexPaths:indexPaths];
            NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
            return @[views, positions];
        };
    }
    return adjustViewsInVisualPositionsHandler;
}

-(ViewsInRepositoryPositionsHandler) rollInViewsInRepositoryPositionsHandler
{
    if (! rollInViewsInRepositoryPositionsHandler) {
        rollInViewsInRepositoryPositionsHandler = ^NSArray *(NSArray *lines, NSArray *indexPaths, NSArray* groupedNullIndexpaths, NSDictionary *linesConfig, NSArray* vanishingViews) {
            // move all symbols to black point , cause roll out may be some time not roll all out . cause the line defined difference ...
            [IterateHelper iterateTwoDimensionArray:QueueViewsHelper.viewsRepository handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
                ((UIView*)obj).center = VIEW.frame.blackPoint;
                return NO;
            }];
            NSMutableArray* views = [QueueViewsHelper getViewsQueuesIn:QueueViewsHelper.viewsRepository lines:lines indexPaths:indexPaths];
            NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
            return @[views, positions];
        };
    }
    return rollInViewsInRepositoryPositionsHandler;
}

-(ViewsInRepositoryPositionsHandler) rollOutViewsInRepositoryPositionsHandler
{
    if (! rollOutViewsInRepositoryPositionsHandler) {
        rollOutViewsInRepositoryPositionsHandler = ^NSArray *(NSArray *lines, NSArray *indexPaths, NSArray* groupedNullIndexpaths, NSDictionary *linesConfig, NSArray* vanishingViews) {
            NSMutableArray* viewsInVisualArea = [PositionsHelper getViewsInContainerInVisualArea];
            NSMutableArray* views = [QueueViewsHelper getViewsQueuesIn:viewsInVisualArea lines:lines indexPaths:indexPaths];
            NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
            return @[views, positions];
        };
    }
    return rollOutViewsInRepositoryPositionsHandler;
}




#pragma mark - score

-(void) scoreWithEffect:(NSArray*)symbols
{
    NSMutableArray* vanishViews = [ArrayHelper eliminateDuplicates: [ArrayHelper translateToOneDimension: symbols]];

    // touch and route not two dimension
    int multiple = [ArrayHelper isTwoDimension: symbols] ? (int)symbols.count : (int)vanishViews.count - MATCH_COUNT;
    multiple = multiple <= 0 ? 1 : multiple;
    
    [self caculateTheScore: vanishViews multiple:multiple];
    NSString* iKey = [NSString stringWithFormat:@"%d", multiple];
    [self showBonusHint: DATA.config[@"Utilities"][@"VanishBonus"] key:iKey multipleTip:0];
}

-(void) chainScoreWithEffect: (NSArray*)symbols continuous:(int)continuous
{
    NSMutableArray* vanishViews = [ArrayHelper eliminateDuplicates: [ArrayHelper translateToOneDimension: symbols]];

    [self caculateTheScore: vanishViews multiple:continuous];
    NSString* iKey = [NSString stringWithFormat:@"%d", continuous];
    [self showBonusHint: DATA.config[@"Utilities"][@"ChainBonus"] key:iKey multipleTip:continuous];
}

-(void) caculateTheScore: (NSArray*)vanishViews multiple:(int)multiple
{
    float totalScore = 0;
    for (int i = 0; i < vanishViews.count; i++) {
        SymbolView* symbol = vanishViews[i];
        float score = symbol.score * multiple;
        totalScore += score;
    }
    VIEW.gameView.scoreLabel.number += totalScore;
    
    // check if passed this season
    if (VIEW.gameView.scoreLabel.number >= ACTION.gameState.clearanceScore) {
        
        MBProgressHUD* hud = nil;
        if (!ACTION.gameState.isClearanced) {
            hud = [self getPassedSeasonHint: 4];
        }
        [self showSeasonHud: hud title:@"Congratulations" scoreDelay:0 messageDelay:2];
        
        ACTION.gameState.isClearanced = YES;
    } else {
        ACTION.gameState.isClearanced = NO;
    }
}

-(void) showBonusHint: (NSDictionary*)configs key:(NSString*)key multipleTip:(int)multiple
{
    NSDictionary* config = [ConfigHelper getSubConfig:configs key:key];
    
    GradientLabel* bonusLabel = [[GradientLabel alloc] init];
    
    [VIEW.actionDurations clear];
    [ACTION.gameEffect designateValuesActionsTo: bonusLabel config:config];
    double totalDuration = [VIEW.actionDurations take];
    
    if ([bonusLabel.text isEqualToString:@""]) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(totalDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [bonusLabel.layer removeAllAnimations];
        [bonusLabel removeFromSuperview];
    });
    
    // center and add to view
    if (multiple >= 1) {
        NSString* appendFormat = config[@"~textMultiFormat"];
        NSString* appendText = [NSString stringWithFormat:appendFormat, multiple];
        bonusLabel.text = [bonusLabel.text stringByAppendingString: appendText];
    }
    [bonusLabel adjustWidthToFontText];
    [VIEW.gameView addSubview: bonusLabel];
    bonusLabel.center = [VIEW.gameView middlePoint];
}







#pragma mark - pass season hint

-(void) showPassedSeasonHint:(int)hideDelay title:(NSString*)title scoreDelay:(int)scoreDelay messageDelay:(int)messageDelay
{
    MBProgressHUD *hud = [self getPassedSeasonHint: hideDelay];
    [self showSeasonHud: hud title:title scoreDelay:scoreDelay messageDelay:messageDelay];
}

-(MBProgressHUD*) getPassedSeasonHint: (int)hideDelay
{
    MBProgressHUD *hud = (MBProgressHUD*)[[ViewHelper getTopView] viewWithTag:SeasonHintHudTag];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:[ViewHelper getTopView] animated:YES];
        hud.tag = SeasonHintHudTag;
        hud.userInteractionEnabled = NO;
        
        hud.mode = MBProgressHUDModeText;
        hud.dimBackground = YES;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay: hideDelay];
    }
    return hud;
}

-(void) showSeasonHud: (MBProgressHUD*)hud title:(NSString*)title scoreDelay:(int)scoreDelay messageDelay:(int)messageDelay
{
    if (!hud) {
        hud = (MBProgressHUD*)[[ViewHelper getTopView] viewWithTag:SeasonHintHudTag];
    }
    if (!hud) return;
    
    hud.labelText = title;
    
    NSString* message = nil;
    if (VIEW.gameView.scoreLabel.number >= ACTION.gameState.clearanceScore) {
        if (ACTION.gameState.currentChapter != [[APPStandUserDefaults objectForKey:User_ChapterIndex] intValue]) {
            message = [NSString stringWithFormat:@"Season %d already unlocked :)", ACTION.gameState.currentChapter + 1];
        } else {
            [APPStandUserDefaults setObject: @(ACTION.gameState.currentChapter + 1) forKey:User_ChapterIndex];  // do no put this in delay, important!!!
            [VIEW.chaptersView.lineScrollView setCurrentIndex: [[APPStandUserDefaults objectForKey:User_ChapterIndex] intValue]];
            
            message = [NSString stringWithFormat:@"Season %d now unlocked :)", [[APPStandUserDefaults objectForKey:User_ChapterIndex] intValue]];
        }
        
    } else {
        message = [NSString stringWithFormat:@"No new season unlocked :("];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(scoreDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        hud.detailsLabelText = [NSString stringWithFormat:@"You got %.0f, clearance is %d", VIEW.gameView.scoreLabel.number, ACTION.gameState.clearanceScore];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(messageDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        hud.labelText = message;
        hud.detailsLabelText = nil;
    });
}


@end
