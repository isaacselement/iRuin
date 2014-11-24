#import "EffectHelper.h"
#import "AppInterface.h"

@implementation EffectHelper
{
    // schedule action
    int imageIndex;
    NSArray* imagesValues ;
    NSMutableDictionary* scheduleTaskConfig;
    
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

-(void) updateScheduleTaskConfigAndRegistryToTask
{
    // handler the config
    imagesValues = DATA.config[@"Utilities"][@"ScheduleTask.view.backgroundView.images"];
    scheduleTaskConfig = [DictionaryHelper deepCopy:DATA.config[@"GAME_LAUNCH_ScheduleTask"]];
    
    // schedule task
    int interval = [DATA.config[@"Utilities"][@"ScheduleTask_Interval"] intValue];
    if (interval == 0) interval = 60;
    [[ScheduledTask sharedInstance] unRegisterSchedule: self];
    [[ScheduledTask sharedInstance] registerSchedule: self timeElapsed:interval repeats:0];
}

-(void) scheduledTask
{
    imageIndex = imageIndex % imagesValues.count;
    NSString* imageName = [imagesValues objectAtIndex: imageIndex];
    imageIndex++;
    
    NSMutableDictionary* config = scheduleTaskConfig[@"view"][@"backgroundView"][@"Executors"][@"1"];
    [config setObject: imageName forKey:@"values"];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:scheduleTaskConfig];
}




#pragma mark - Bonus Effect

-(void) bonusEffectWithScore: (int)bonusScore
{
    NumberLabel* scoreLabel = VIEW.gameView.scoreLabel;
    
    // bonus label
    UILabel* bonusLabel = [[UILabel alloc] initWithFrame: CanvasRect(0, 0, 100, 100)];
    bonusLabel.font = [UIFont systemFontOfSize: CanvasFontSize(100)];
    bonusLabel.textColor = [UIColor flatGreenColor];
    [scoreLabel addSubview: bonusLabel];
    
    scoreLabel.number += bonusScore;
    
    bonusLabel.text = [NSString stringWithFormat:@"+%d", bonusScore];
    [bonusLabel adjustWidthToFontText];
    bonusLabel.center = [scoreLabel middlePoint];
    
    // animation
    CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath: @"transform.scale"];
    scaleAnimation.fromValue = @(1.0);
    scaleAnimation.toValue = @(3.0);
    scaleAnimation.duration = 0.5;
    [bonusLabel.layer addAnimation: scaleAnimation forKey:@""];
    
    [UIView animateWithDuration: 0.6 animations:^{
        
        bonusLabel.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [bonusLabel removeFromSuperview];
        
    }];
}




@end
