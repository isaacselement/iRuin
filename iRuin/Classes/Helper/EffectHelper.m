#import "EffectHelper.h"
#import "AppInterface.h"

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





#pragma mark - Bonus Effect

-(void) scoreWithEffect:(NSArray*)symbols
{
    NSMutableArray* vanishViews = [ArrayHelper eliminateDuplicates: [ArrayHelper translateToOneDimension: symbols]];

    int multiple = 1;
    // touch and route not two dimension
    if ([ArrayHelper isTwoDimension: symbols]) {
        multiple = symbols.count;
        
    } else {
        multiple = vanishViews.count - MATCH_COUNT;
        
    }
    multiple = multiple <= 0 ? 1 : multiple;
    
    float totalScore = 0;
    for (int i = 0; i < vanishViews.count; i++) {
        SymbolView* symbol = vanishViews[i];
        float score = symbol.score * multiple;
        totalScore += score;
    }
    VIEW.gameView.scoreLabel.number += totalScore;
    
    NSString* iKey = [NSString stringWithFormat:@"%d", multiple];
    if (multiple > 1) {
        int plus = 0;
        if (!DATA.config[@"Utilities"][@"VanishBonus"][iKey]) {
            plus = multiple;
        }
        [self showBonusHint: DATA.config[@"Utilities"][@"VanishBonus"] key:iKey plus:plus];
    }
}

-(void) chainScoreWithEffect: (NSArray*)symbols continuous:(int)continuous
{
    NSMutableArray* vanishViews = [ArrayHelper eliminateDuplicates: [ArrayHelper translateToOneDimension: symbols]];

    float totalScore = 0;
    for (int i = 0; i < vanishViews.count; i++) {
        SymbolView* symbol = vanishViews[i];
        float score = symbol.score * continuous;
        totalScore += score;
    }
    VIEW.gameView.scoreLabel.number += totalScore;
    
    NSString* iKey = [NSString stringWithFormat:@"%d", continuous];
    [self showBonusHint: DATA.config[@"Utilities"][@"ChainBonus"] key:iKey plus:continuous];
}





-(void) showBonusHint: (NSDictionary*)configs key:(NSString*)key plus:(int)plus
{
    NSDictionary* config = configs[key];
    if (! config) {
        config = configs[@"default"];
    }
    if (configs[@"common"]) {
        config = [DictionaryHelper combines:configs[@"common"] with:config];
    }
    
    
    GradientLabel* bonusLabel = [[GradientLabel alloc] init];
    
    [VIEW.actionDurations clear];
    [ACTION.gameEffect designateValuesActionsTo: bonusLabel config:config];
    double totalDuration = [VIEW.actionDurations take];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(totalDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [bonusLabel.layer removeAllAnimations];
        [bonusLabel removeFromSuperview];
    });
    
    // center and add to view
    if (plus >= 1) {
        bonusLabel.text = [bonusLabel.text stringByAppendingFormat: @" %d", plus];
    }
    [bonusLabel adjustWidthToFontText];
    [VIEW.gameView addSubview: bonusLabel];
    bonusLabel.center = [VIEW.gameView middlePoint];
}


@end
