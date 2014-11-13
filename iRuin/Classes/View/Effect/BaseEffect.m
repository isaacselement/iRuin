#import "BaseEffect.h"
#import "AppInterface.h"


@implementation BaseEffect
{
    NSDictionary* linesConfigs;
    NSDictionary* actionsConfigs;
    NSDictionary* positionsConfigs;
}

@synthesize event;




#pragma mark - Subclass Override Methods
- (void)effectInitialize
{
    linesConfigs = DATA.config[VISUAL_POSITIONS];
    positionsConfigs = DATA.config[CONFIG_POSITIONS];
    actionsConfigs = DATA.config[SYMBOLS_ActionExecutors];
    
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
    [event eventSymbolsWillRollIn];
    [VIEW.actionDurations clear];
    [self startSymbolsRollIn];
    double totalDuration = [VIEW.actionDurations take];
    
    // cause , roll in before did roll out call (the game start again)
    [NSObject cancelPreviousPerformRequestsWithTarget:event selector:@selector(eventSymbolsDidRollOut) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:event selector:@selector(eventSymbolsDidRollIn) object:nil];
    [event performSelector:@selector(eventSymbolsDidRollIn) withObject:nil afterDelay:totalDuration];
}

-(void) effectStartRollOut
{
    [event eventSymbolsWillRollOut];
    [VIEW.actionDurations clear];
    [self startSymbolsRollOut];
    double totalDuration = [VIEW.actionDurations take];
    
    // cause , roll out before did roll in call (the game back button clicked)
    [NSObject cancelPreviousPerformRequestsWithTarget:event selector:@selector(eventSymbolsDidRollIn) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:event selector:@selector(eventSymbolsDidRollOut) object:nil];
    [event performSelector:@selector(eventSymbolsDidRollOut) withObject:nil afterDelay:totalDuration];
}


-(void)effectStartVanish: (NSMutableArray*)symbols
{
    // get the null rows and columns
    NSMutableArray* nullRowColumns = [NSMutableArray array];
    NSArray* indexPathsRepository = QueueIndexPathParser.indexPathsRepository;
    NSArray* symbolsAtContainer = QueueViewsHelper.viewsInVisualArea;
    for (NSInteger i = 0; i < symbols.count; i++) {
        SymbolView* symbol = symbols[i];
        
        if (symbol.row == -1 || symbol.column == -1) {
            DLOG(@"ERROR!!!! ++++");
            return;
        }
        
        int row = symbol.row;
        int column = symbol.column;
        [[symbolsAtContainer objectAtIndex: row] replaceObjectAtIndex: column withObject:[NSNull null]];
        [nullRowColumns addObject: [[indexPathsRepository objectAtIndex: row] objectAtIndex: column]];
        
        symbol.row = -1;
        symbol.column = -1;
    }
    
    
    
    NSMutableArray* vanishingViews = [ArrayHelper eliminateDuplicates: symbols];
    [event eventSymbolsWillVanish: vanishingViews];
    [VIEW.actionDurations clear];
    [self startSymbolsVanish: vanishingViews];
    double vanishTotalDuration = [VIEW.actionDurations take];
    [event performSelector: @selector(eventSymbolsDidVanish:) withObject:vanishingViews afterDelay:vanishTotalDuration];
    
    
    if ([DATA.config[Squeeze] boolValue]){
        
        [event eventSymbolsWillSqueeze];
        [VIEW.actionDurations clear];
        [self startSymbolsSqueeze: nullRowColumns vanishingViews:vanishingViews vanishDuration:vanishTotalDuration];
        double squeezeTotalDuration = [VIEW.actionDurations take];
        [event performSelector: @selector(eventSymbolsDidSqueeze) withObject:nil afterDelay:squeezeTotalDuration];
        
    } else {

        [event eventSymbolsWillAdjusts];
        [VIEW.actionDurations clear];
        [self startSymbolsAdjusts: nullRowColumns delay:vanishTotalDuration];
        double adjustTotalDuration = [VIEW.actionDurations take];
        [event performSelector: @selector(eventSymbolsDidAdjusts) withObject:nil afterDelay:adjustTotalDuration];
        

        [event eventSymbolsWillFillIn];
        [VIEW.actionDurations clear];
        [self startSymbolsFillIn: vanishingViews delay:vanishTotalDuration + adjustTotalDuration];
        double filInTotalDuration = [VIEW.actionDurations take];
        [event performSelector: @selector(eventSymbolsDidFillIn) withObject:nil afterDelay:filInTotalDuration];
        
    }
    
}







#pragma mark - Private Methods

-(void) startSymbolsVanish: (NSArray*)views
{
    [VIEW.actionExecutorManager runActionExecutors:actionsConfigs[Vanish] onObjects:views values:nil baseTimes:nil];
}

-(void) startSymbolsRollIn
{
    [self startSymbolsRoll:linesConfigs[RollIn] config:positionsConfigs[RollIn] actionsConfig:actionsConfigs[RollIn] inViews:QueueViewsHelper.viewsRepository];
}

-(void) startSymbolsRollOut
{
    [self startSymbolsRoll:linesConfigs[RollOut] config:positionsConfigs[RollOut] actionsConfig:actionsConfigs[RollOut] inViews:QueueViewsHelper.viewsInVisualArea];
}





-(void) startSymbolsRoll: (NSArray*)lines config:(NSDictionary*)config actionsConfig:(NSArray*)actionsConfig inViews:(NSArray*)inViews
{
    NSMutableArray* nullRowColumns = [NSMutableArray array];
    [IterateHelper iterateTwoDimensionArray:QueueViewsHelper.viewsInVisualArea handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
        [nullRowColumns addObject:[[QueueIndexPathParser.indexPathsRepository objectAtIndex:outterIndex] objectAtIndex: innerIndex]];
        return NO;
    }];
    
    [self roll:lines config:config actionsConfig:actionsConfig delay:0 nullRowColumns:nullRowColumns inViews:inViews];
}



-(void) startSymbolsAdjusts: (NSArray*)nullRowColumns delay:(double)delay
{
    [self roll:linesConfigs[Adjusts] config:positionsConfigs[Adjusts] actionsConfig:actionsConfigs[Adjusts] delay:delay nullRowColumns:nullRowColumns inViews:QueueViewsHelper.viewsInVisualArea];
}



-(void) startSymbolsSqueeze: (NSArray*)nullRowColumns vanishingViews:(NSArray*)vanishingViews vanishDuration:(double)vanishDuration
{
    [self roll: linesConfigs[Squeeze_Adjust] config:positionsConfigs[Squeeze_Adjust] actionsConfig:actionsConfigs[Squeeze_Adjust] delay:vanishDuration nullRowColumns:nullRowColumns inViews:[QueueViewsHelper viewsInVisualArea]];
    
    [self fillIn: linesConfigs[Squeeze_FillIn] config:positionsConfigs[Squeeze_FillIn] actionsConfig:actionsConfigs[Squeeze_FillIn] vanishingViews:vanishingViews delay:vanishDuration];
}



-(void) startSymbolsFillIn:(NSArray*)vanishingViews delay:(double)delay
{
    [self fillIn:linesConfigs[FillIn] config:positionsConfigs[FillIn] actionsConfig:actionsConfigs[FillIn] vanishingViews:vanishingViews delay:delay];
}

-(void) roll: (NSArray*)lines config:(NSDictionary*)config actionsConfig:(NSArray*)actionsConfig delay:(double)delay nullRowColumns:(NSArray*)nullRowColumns inViews:(NSArray*)inViews
{
    NSDictionary* linesConfig = config[LINES];
    
    NSDictionary* indexPathsConfig = config[INDEXPATHS];
    BOOL isReverse = [indexPathsConfig[IsReverse] boolValue];
    BOOL isBackward = [indexPathsConfig[IsBackward] boolValue];
    BOOL isColumnBase = [indexPathsConfig[IsColumnBase] boolValue];
    
    NSMutableArray* nullIndexPaths = [QueueIndexPathParser getIndexPathsIn: lines elements:nullRowColumns];
    NSArray* groupedNullIndexpaths = [QueueIndexPathParser groupTheNullIndexPaths: nullIndexPaths isNullIndexPathsBreakWhenNotCoterminous:NO isColumnBase:isColumnBase];
    NSArray* indexPaths = [QueueIndexPathParser assembleIndexPaths:lines groupedNullIndexpaths:groupedNullIndexpaths isBackward:isBackward isColumnBase:isColumnBase isReverse:isReverse];
    
    NSMutableArray* views = [QueueViewsHelper getViewsQueuesIn:inViews lines:lines indexPaths:indexPaths];
    NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
    NSMutableArray* baseTimes = [self getBaseTimesAccordingToViews: views delay:delay];
    
    [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:views values:positions baseTimes:baseTimes];
    [PositionsHelper updateViewsRowsColumnsInVisualArea: views];
}

-(void) fillIn: (NSArray*)lines config:(NSDictionary*)config actionsConfig:(NSArray*)actionsConfig vanishingViews:(NSArray*)vanishingViews delay:(double)delay
{
    NSDictionary* linesConfig = config[LINES];
    
    NSDictionary* indexPathsConfig = config[INDEXPATHS];
    BOOL isReverse = [indexPathsConfig[IsReverse] boolValue];
    BOOL isBackward = [indexPathsConfig[IsBackward] boolValue];
    BOOL isColumnBase = [indexPathsConfig[IsColumnBase] boolValue];
    
    NSMutableArray* nullRowColumns = [PositionsHelper getIndexPathsNullInVisualAreaViews];
    NSMutableArray* nullIndexPaths = [QueueIndexPathParser getIndexPathsIn: lines elements:nullRowColumns];
    NSArray* groupedNullIndexpaths = [QueueIndexPathParser groupTheNullIndexPaths: nullIndexPaths isNullIndexPathsBreakWhenNotCoterminous:YES isColumnBase:isColumnBase];
    NSArray* indexPaths = [QueueIndexPathParser assembleIndexPaths:lines groupedNullIndexpaths:groupedNullIndexpaths isBackward:isBackward isColumnBase:isColumnBase isReverse:isReverse];
    
    // TODO: If not enough ~~~~~~, cause may vanish many ~~~~~  !
    NSMutableArray* uselessViews = [QueueViewsHelper getUselessViews];
    for (UIView* vanishingView in vanishingViews) {
        [uselessViews removeObject: vanishingView];
    }
    
    int count = 0 ;
    NSMutableArray* views = [NSMutableArray array];
    for (NSUInteger i = 0; i < groupedNullIndexpaths.count; i++) {
        NSArray* oneGroupedNullIndexpaths = groupedNullIndexpaths[i];
        NSMutableArray* innerViews = [NSMutableArray array];
        for (NSUInteger j = 0; j < oneGroupedNullIndexpaths.count; j++) {
            UIView* view = [uselessViews objectAtIndex:count];
            [innerViews addObject: view];
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
    
    [IterateHelper iterateTwoDimensionArray: views handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
        SymbolView* symbol = (SymbolView*)obj;
        [symbol restore];
        symbol.identification = [SymbolView getOneRandomSymbolIdentification];
        return NO;
    }];
    
    NSMutableArray* baseTimes = [self getBaseTimesAccordingToViews: views delay:delay];
    
    [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:views values:positions baseTimes:baseTimes];
    [PositionsHelper updateViewsRowsColumnsInVisualArea: views];
}






#pragma mark - 


-(NSMutableArray*) getBaseTimesAccordingToViews: (NSArray*)views delay:(double)delay
{
    if (delay == 0) return nil;
    
    NSNumber* delayNum = @(delay);
    NSMutableArray* baseTimes = [NSMutableArray array];
    for (NSArray* innerViews in views) {
        NSMutableArray* innerBaseTimes = [NSMutableArray array];
        for (int i = 0; i < innerViews.count; i++) {
            [innerBaseTimes addObject:delayNum];
        }
        [baseTimes addObject: innerBaseTimes];
    }
    return baseTimes;
}



@end
