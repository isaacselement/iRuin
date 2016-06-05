#import "BaseEffect.h"
#import "AppInterface.h"

@implementation BaseEffect
{
    NSDictionary* linesConfigs;
    NSDictionary* phasesConfigs;
    NSDictionary* actionsConfigs;
    NSDictionary* positionsConfigs;
    
    ViewsInRepositoryPositionsHandler fillInViewsPositionsHandler;
    ViewsInRepositoryPositionsHandler adjustViewsInVisualPositionsHandler;
    ViewsInRepositoryPositionsHandler rollInViewsInRepositoryPositionsHandler;
    ViewsInRepositoryPositionsHandler rollOutViewsInRepositoryPositionsHandler;
    
    
    BOOL isSqueeze ;
    double fillAdvanceAdjustTime ;
}

@synthesize event;


#pragma mark - Subclass Override Methods

- (void)effectInitialize
{
    linesConfigs = DATA.config[VISUAL_POSITIONS];
    phasesConfigs = DATA.config[PHASES_POSITIONS];
    positionsConfigs = DATA.config[CONFIG_POSITIONS];
    actionsConfigs = DATA.config[SYMBOLS_ACTIONEXECUTORS];
    
    EffectHelper* effectHelper = [EffectHelper getInstance];
    fillInViewsPositionsHandler = [effectHelper fillInViewsPositionsHandler];
    adjustViewsInVisualPositionsHandler = [effectHelper adjustViewsInVisualPositionsHandler];;
    rollInViewsInRepositoryPositionsHandler = [effectHelper rollInViewsInRepositoryPositionsHandler];
    rollOutViewsInRepositoryPositionsHandler = [effectHelper rollOutViewsInRepositoryPositionsHandler];
    
    
    isSqueeze = [DATA.config[Squeeze] boolValue];
    fillAdvanceAdjustTime = [DATA.config[FillAdvanceAdjustTime] doubleValue];
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


-(void)effectStartVanish: (NSArray*)symbols
{
    // two dimension or one dimension, nil return
    if (!symbols) return;
    [event eventSymbolsWillVanish: symbols];
    
    NSArray* symbolsAtContainer = QueueViewsHelper.viewsInVisualArea;
    NSMutableArray* vanishViews = [ArrayHelper translateToOneDimension: symbols];
    
    ACTION.gameState.vanishAmount += (int)vanishViews.count;
    
    for (SymbolView* symbol in vanishViews){
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
    [self startSymbolsVanish: symbols];
    double vanishDuration = [VIEW.actionDurations take];
    [event performSelector: @selector(eventSymbolsDidVanish:) withObject:symbols afterDelay:vanishDuration];
    
    // adjust , fill or squeeze
    [self effectStartAdjustFillSqueeze:vanishViews vanishDuration:vanishDuration];
}


-(void) effectStartAdjustFillSqueeze: (NSArray*)vanishingViews vanishDuration:(double)vanishDuration
{
    if (isSqueeze){
        
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
        
        // maybe no adjust, if the top line symbol vanish
        double fillDelayTime = vanishDuration + adjustDuration;
        if (adjustDuration != 0) {
            fillDelayTime -= fillAdvanceAdjustTime;
        }
        
        [VIEW.actionDurations clear];
        [self startSymbolsFillIn: vanishingViews delay:fillDelayTime];
        double filInDuration = [VIEW.actionDurations take];
        [event eventSymbolsWillFillIn];
        [NSObject cancelPreviousPerformRequestsWithTarget:event selector:@selector(eventSymbolsDidFillIn) object:nil];
        [event performSelector: @selector(eventSymbolsDidFillIn) withObject:nil afterDelay:filInDuration];
        
    }
}

#pragma mark - Private Methods

-(void) startSymbolsVanish: (NSArray*)symbols
{
    [VIEW.actionExecutorManager runActionExecutors:actionsConfigs[Vanish] onObjects:symbols values:nil baseTimes:nil];
}

-(void) startSymbolsRollIn
{
    [QueueViewsHelper replaceViewsInVisualAreaWithNull];
    
    [self roll:linesConfigs[phasesConfigs[RollIn]] config:positionsConfigs[RollIn] actionsConfig:actionsConfigs[RollIn] isGroupBreak:NO delay:0 vanishingViews:nil viewspositionsHandler:rollInViewsInRepositoryPositionsHandler];
}

-(void) startSymbolsRollOut
{
    [QueueViewsHelper replaceViewsInVisualAreaWithNull];
    
    [self roll:linesConfigs[phasesConfigs[RollOut]] config:positionsConfigs[RollOut] actionsConfig:actionsConfigs[RollOut] isGroupBreak:NO delay:0 vanishingViews:nil viewspositionsHandler:rollOutViewsInRepositoryPositionsHandler];
}

-(void) startSymbolsAdjusts:(NSArray*)vanishingViews delay:(double)delay
{
    [self roll:linesConfigs[phasesConfigs[Adjusts]] config:positionsConfigs[Adjusts] actionsConfig:actionsConfigs[Adjusts] isGroupBreak:NO delay:delay vanishingViews:vanishingViews viewspositionsHandler:adjustViewsInVisualPositionsHandler];
}

-(void) startSymbolsFillIn:(NSArray*)vanishingViews delay:(double)delay
{
    [self roll:linesConfigs[phasesConfigs[FillIn]] config:positionsConfigs[FillIn] actionsConfig:actionsConfigs[FillIn] isGroupBreak:YES delay:delay vanishingViews:vanishingViews viewspositionsHandler:fillInViewsPositionsHandler];
}

-(void) startSymbolsSqueeze:(NSArray*)vanishingViews vanishDuration:(double)vanishDuration
{
    [self roll:linesConfigs[phasesConfigs[Squeeze_Adjust]] config:positionsConfigs[Squeeze_Adjust] actionsConfig:actionsConfigs[Squeeze_Adjust] isGroupBreak:NO delay:vanishDuration vanishingViews:vanishingViews viewspositionsHandler:adjustViewsInVisualPositionsHandler];
    
    [self roll:linesConfigs[phasesConfigs[Squeeze_FillIn]] config:positionsConfigs[Squeeze_FillIn] actionsConfig:actionsConfigs[Squeeze_FillIn] isGroupBreak:YES delay:vanishDuration vanishingViews:vanishingViews viewspositionsHandler:fillInViewsPositionsHandler];
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