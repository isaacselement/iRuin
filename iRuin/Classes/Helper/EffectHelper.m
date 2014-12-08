#import "EffectHelper.h"
#import "AppInterface.h"

@implementation EffectHelper
{
    // schedule action
    int scheduleTaskTimes;
    
    int scheduleViewValueIndex;

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
            for (UIView* vanishingSymbol in vanishingViews) {
                [uselessViews removeObject: vanishingSymbol];
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




#pragma mark - Schedule Action
-(void) unRegisterScheduleTaskAccordingConfig
{
    [[ScheduledTask sharedInstance] unRegisterSchedule: self];
}

-(void) registerScheduleTaskAccordingConfig
{
    [[ScheduledTask sharedInstance] unRegisterSchedule: self];
    [[ScheduledTask sharedInstance] registerSchedule: self timeElapsed:1 repeats:0];
}

-(void) scheduledTask
{
    scheduleTaskTimes++;
    
    
    // view
    int viewInterval = [DATA.config[@"Utilities"][@"ScheduleTask.view.interval"] intValue];
    if (viewInterval == 0) viewInterval = 60;
    
    if (scheduleTaskTimes % viewInterval == 0) {
        NSArray* values = DATA.config[@"Utilities"][@"ScheduleTask.view.values"];
        NSMutableDictionary* scheduleTaskConfig = DATA.config[@"GAME_LAUNCH_ScheduleTask"];
        NSMutableDictionary* valuesConfig = scheduleTaskConfig[@"view"][@"backgroundView"][@"Executors"][@"1"];
        
        scheduleViewValueIndex = scheduleViewValueIndex % [values count];
        [valuesConfig setObject: [values objectAtIndex: scheduleViewValueIndex] forKey:@"values"];
        scheduleViewValueIndex++;
        
        [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:scheduleTaskConfig];
    }
    
    // cue
    int cueInterval = [DATA.config[@"Utilities"][@"ScheduleTask.audioCue.interval"] intValue];
    if (cueInterval == 0) cueInterval = 5;
    if (scheduleTaskTimes % cueInterval == 0) {
        NSMutableArray* values = DATA.config[@"Utilities"][@"AudioCues"];
        VIEW.chaptersView.cueLabel.text = [values firstObject];
    }
    
}




#pragma mark - Bonus Effect

-(void) bonusEffectWithScore: (int)bonusScore
{
    NumberLabel* scoreLabel = VIEW.gameView.scoreLabel;
    
    // bonus label
    UILabel* bonusLabel = [[UILabel alloc] initWithFrame: CanvasRect(0, 0, 100, 100)];
    bonusLabel.font = [UIFont systemFontOfSize: CanvasFontSize(100)];
    bonusLabel.textColor = [ColorHelper parseColor:@(bonusScore)];
    [scoreLabel addSubview: bonusLabel];
    
    scoreLabel.number += bonusScore;
    
    bonusLabel.text = [NSString stringWithFormat:@"+%d", bonusScore];
    [bonusLabel adjustWidthToFontText];
    bonusLabel.center = [scoreLabel middlePoint];
    
    [UIView transitionWithView: bonusLabel duration:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        bonusLabel.alpha = 0;
        bonusLabel.layer.transform = CATransform3DMakeScale(3, 3, 3);
        
    } completion:^(BOOL finished) {
        
        [bonusLabel removeFromSuperview];
        
    }];
}




@end
