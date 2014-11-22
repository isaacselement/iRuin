#import "BaseEffect.h"
#import "AppInterface.h"

@implementation BaseEffect
{
    NSDictionary* linesConfigs;
    NSDictionary* actionsConfigs;
    NSDictionary* positionsConfigs;
    
    ViewsInRepositoryPositionsHandler fillInViewsPositionsHandler;
    ViewsInRepositoryPositionsHandler adjustViewsInVisualPositionsHandler;
    ViewsInRepositoryPositionsHandler rollInViewsInRepositoryPositionsHandler;
    ViewsInRepositoryPositionsHandler rollOutViewsInRepositoryPositionsHandler;

}

@synthesize event;


#pragma mark - Subclass Override Methods

- (void)effectInitialize
{
    linesConfigs = DATA.config[VISUAL_POSITIONS];
    positionsConfigs = DATA.config[CONFIG_POSITIONS];
    actionsConfigs = DATA.config[SYMBOLS_ActionExecutors];
    
    EffectHelper* effectHelper = [EffectHelper getInstance];
    fillInViewsPositionsHandler = [effectHelper fillInViewsPositionsHandler];
    adjustViewsInVisualPositionsHandler = [effectHelper adjustViewsInVisualPositionsHandler];;
    rollInViewsInRepositoryPositionsHandler = [effectHelper rollInViewsInRepositoryPositionsHandler];
    rollOutViewsInRepositoryPositionsHandler = [effectHelper rollOutViewsInRepositoryPositionsHandler];
}
-(void) effectUnInitialize
{
}
- (void)effectTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    if (symbol && actionsConfigs[TouchesBegan]) {
        [VIEW.actionExecutorManager runActionExecutors:actionsConfigs[TouchesBegan] onObjects:@[symbol] values:nil baseTimes:nil];
    }
}
- (void)effectTouchesMoved:(SymbolView*)symbol location:(CGPoint)location
{
    if (symbol && actionsConfigs[TouchesMoved]) {
        [VIEW.actionExecutorManager runActionExecutors:actionsConfigs[TouchesMoved] onObjects:@[symbol] values:nil baseTimes:nil];
    }
}
- (void)effectTouchesEnded:(SymbolView*)symbol location:(CGPoint)location
{
    if (symbol && actionsConfigs[TouchesEnded]) {
        [VIEW.actionExecutorManager runActionExecutors:actionsConfigs[TouchesEnded] onObjects:@[symbol] values:nil baseTimes:nil];
    }
}
- (void)effectTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    if (symbol && actionsConfigs[TouchesCancelled]) {
        [VIEW.actionExecutorManager runActionExecutors:actionsConfigs[TouchesCancelled] onObjects:@[symbol] values:nil baseTimes:nil];
    }
}




#pragma mark - Public Methods

-(void) effectStartRollIn
{
    [VIEW.actionDurations clear];
    [self startSymbolsRollIn];
    double totalDuration = [VIEW.actionDurations take];
    [event eventSymbolsWillRollIn];
    // cause , roll in before did roll out call (the game start again)
    [NSObject cancelPreviousPerformRequestsWithTarget:event selector:@selector(eventSymbolsDidRollOut) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:event selector:@selector(eventSymbolsDidRollIn) object:nil];
    [event performSelector:@selector(eventSymbolsDidRollIn) withObject:nil afterDelay:totalDuration];
}

-(void) effectStartRollOut
{
    [VIEW.actionDurations clear];
    [self startSymbolsRollOut];
    double totalDuration = [VIEW.actionDurations take];
    [event eventSymbolsWillRollOut];
    // cause , roll out before did roll in call (the game back button clicked)
    [NSObject cancelPreviousPerformRequestsWithTarget:event selector:@selector(eventSymbolsDidRollIn) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:event selector:@selector(eventSymbolsDidRollOut) object:nil];
    [event performSelector:@selector(eventSymbolsDidRollOut) withObject:nil afterDelay:totalDuration];
}


-(void)effectStartVanish: (NSMutableArray*)symbols
{
    NSArray* symbolsAtContainer = QueueViewsHelper.viewsInVisualArea;
    NSMutableArray* vanishViews = [ArrayHelper eliminateDuplicates: symbols];
    for (NSInteger i = 0; i < vanishViews.count; i++) {
        SymbolView* symbol = vanishViews[i];
        if (symbol.row == -1 || symbol.column == -1) {
            DLOG(@"ERROR!!!! ++++");
            continue;
        }
        int row = symbol.row;
        int column = symbol.column;
        [[symbolsAtContainer objectAtIndex: row] replaceObjectAtIndex: column withObject:[NSNull null]];
        symbol.row = -1;
        symbol.column = -1;
    }
    
    // vanish
    [VIEW.actionDurations clear];
    [self startSymbolsVanish: vanishViews];
    double vanishDuration = [VIEW.actionDurations take];
    [event eventSymbolsWillVanish: vanishViews];
    [event performSelector: @selector(eventSymbolsDidVanish:) withObject:vanishViews afterDelay:vanishDuration];
    
    // adjust , fill or squeeze
    [self startSymbolsAdjustFillSqueeze:vanishViews vanishDuration:vanishDuration];
}


-(void) startSymbolsAdjustFillSqueeze: (NSArray*)vanishingViews vanishDuration:(double)vanishDuration
{
    if ([DATA.config[Squeeze] boolValue]){
        
        [VIEW.actionDurations clear];
        [self startSymbolsSqueeze:vanishingViews vanishDuration:vanishDuration];
        double squeezeDuration = [VIEW.actionDurations take];
        [event eventSymbolsWillSqueeze];
        [NSObject cancelPreviousPerformRequestsWithTarget:event selector:@selector(eventSymbolsDidSqueeze) object:nil];
        [event performSelector: @selector(eventSymbolsDidSqueeze) withObject:nil afterDelay:squeezeDuration];
        
    } else {
        
        [VIEW.actionDurations clear];
        [self startSymbolsAdjusts:vanishingViews delay:vanishDuration];
        double adjustDuration = [VIEW.actionDurations take];
        [event eventSymbolsWillAdjusts];
        [NSObject cancelPreviousPerformRequestsWithTarget:event selector:@selector(eventSymbolsDidAdjusts) object:nil];
        [event performSelector: @selector(eventSymbolsDidAdjusts) withObject:nil afterDelay:adjustDuration];
        
        
        [VIEW.actionDurations clear];
        [self startSymbolsFillIn: vanishingViews delay:(vanishDuration + adjustDuration)];
        double filInDuration = [VIEW.actionDurations take];
        [event eventSymbolsWillFillIn];
        [NSObject cancelPreviousPerformRequestsWithTarget:event selector:@selector(eventSymbolsDidFillIn) object:nil];
        [event performSelector: @selector(eventSymbolsDidFillIn) withObject:nil afterDelay:filInDuration];
        
    }
}





#pragma mark - Private Methods

-(void) startSymbolsVanish: (NSArray*)views
{
    [VIEW.actionExecutorManager runActionExecutors:actionsConfigs[Vanish] onObjects:views values:nil baseTimes:nil];
}

-(void) startSymbolsRollIn
{
    [QueueViewsHelper replaceViewsInVisualAreaWithNull];
    
    [self roll:linesConfigs[RollIn] config:positionsConfigs[RollIn] actionsConfig:actionsConfigs[RollIn] isGroupBreak:NO delay:0 vanishingViews:nil viewspositionsHandler:rollInViewsInRepositoryPositionsHandler];
}

-(void) startSymbolsRollOut
{
    [QueueViewsHelper replaceViewsInVisualAreaWithNull];
    
    [self roll:linesConfigs[RollOut] config:positionsConfigs[RollOut] actionsConfig:actionsConfigs[RollOut] isGroupBreak:NO delay:0 vanishingViews:nil viewspositionsHandler:rollOutViewsInRepositoryPositionsHandler];
}

-(void) startSymbolsAdjusts:(NSArray*)vanishingViews delay:(double)delay
{
    [self roll:linesConfigs[Adjusts] config:positionsConfigs[Adjusts] actionsConfig:actionsConfigs[Adjusts] isGroupBreak:NO delay:delay vanishingViews:vanishingViews viewspositionsHandler:adjustViewsInVisualPositionsHandler];
}

-(void) startSymbolsFillIn:(NSArray*)vanishingViews delay:(double)delay
{
    [self roll:linesConfigs[FillIn] config:positionsConfigs[FillIn] actionsConfig:actionsConfigs[FillIn] isGroupBreak:YES delay:delay vanishingViews:vanishingViews viewspositionsHandler:fillInViewsPositionsHandler];
}

-(void) startSymbolsSqueeze:(NSArray*)vanishingViews vanishDuration:(double)vanishDuration
{
    [self roll:linesConfigs[Squeeze_Adjust] config:positionsConfigs[Squeeze_Adjust] actionsConfig:actionsConfigs[Squeeze_Adjust] isGroupBreak:NO delay:vanishDuration vanishingViews:vanishingViews viewspositionsHandler:adjustViewsInVisualPositionsHandler];
    
    [self roll:linesConfigs[Squeeze_FillIn] config:positionsConfigs[Squeeze_FillIn] actionsConfig:actionsConfigs[Squeeze_FillIn] isGroupBreak:YES delay:vanishDuration vanishingViews:vanishingViews viewspositionsHandler:fillInViewsPositionsHandler];
}




-(void) roll: (NSArray*)lines config:(NSDictionary*)config actionsConfig:(NSArray*)actionsConfig isGroupBreak:(BOOL)isGroupBreak delay:(double)delay vanishingViews:(NSArray*)vanishingViews viewspositionsHandler:(NSArray*(^)(NSArray* lines, NSArray* indexPaths, NSArray* groupedNullIndexpaths, NSDictionary* linesConfig, NSArray* vanishingView))viewspositionsHandler
{
    NSDictionary* linesConfig = config[LINES];
    
    NSDictionary* indexPathsConfig = config[INDEXPATHS];
    BOOL isReverse = [indexPathsConfig[IsReverse] boolValue];
    BOOL isBackward = [indexPathsConfig[IsBackward] boolValue];
    BOOL isColumnBase = [indexPathsConfig[IsColumnBase] boolValue];
    
    NSMutableArray* nullRowColumns = [PositionsHelper getNullIndexPathsInVisualAreaViews];
    NSMutableArray* nullIndexPaths = [QueueIndexPathParser getIndexPathsIn: lines elements:nullRowColumns];
    NSArray* groupedNullIndexpaths = [QueueIndexPathParser groupTheNullIndexPaths: nullIndexPaths isNullIndexPathsBreakWhenNotCoterminous:isGroupBreak isColumnBase:isColumnBase];
    NSArray* indexPaths = [QueueIndexPathParser assembleIndexPaths:lines groupedNullIndexpaths:groupedNullIndexpaths isBackward:isBackward isColumnBase:isColumnBase isReverse:isReverse];
    
    NSArray* array = viewspositionsHandler(lines, indexPaths, groupedNullIndexpaths, linesConfig, vanishingViews);
    NSMutableArray* views = [array firstObject];
    NSMutableArray* positions = [array lastObject];
    NSMutableArray* baseTimes = [QueueTimeCalculator getBaseTimesAccordingToViews: views delay:delay];
    
    [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:views values:positions baseTimes:baseTimes];
    [PositionsHelper updateViewsRowsColumnsInVisualArea: views];
}



@end
