#import "BaseEffect.h"
#import "AppInterface.h"


#define VISUAL_POSITIONS @"VISUAL.POSITIONS"
#define CONFIG_POSITIONS @"CONFIG.POSITIONS"
#define SYMBOLS_ActionExecutors @"SYMBOLS_ActionExecutors"


#define RollIn @"RollIn"
#define RollOut @"RollOut"

#define Vanish @"Vanish"

#define Adjusts @"Adjusts"
#define FillIn @"FillIn"

#define Squeeze @"Squeeze"
#define Squeeze_Adjust @"Squeeze.Adjust"
#define Squeeze_FillIn @"Squeeze.FillIn"


#define LINES @"LINES"
#define INDEXPATHS @"INDEXPATHS"

#define IsBackward @"isBackward"
#define IsColumnBase @"isColumnBase"


#define TouchesBegan @"TouchesBegan"
#define TouchesMoved @"TouchesMoved"
#define TouchesEnded @"TouchesEnded"
#define TouchesCancelled @"TouchesCancelled"



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
    [event performSelector:@selector(eventSymbolsDidRollIn) withObject:nil afterDelay:totalDuration];
}

-(void) effectStartRollOut
{
    [event eventSymbolsWillRollOut];
    [VIEW.actionDurations clear];
    [self startSymbolsRollOut];
    double totalDuration = [VIEW.actionDurations take];
    [event performSelector:@selector(eventSymbolsDidRollOut) withObject:nil afterDelay:totalDuration];
}


-(void)effectStartVanish: (NSMutableArray*)symbols
{
    NSMutableArray* vanishingViews = [ArrayHelper eliminateDuplicates: symbols];
    [event eventSymbolsWillVanish: vanishingViews];
    [VIEW.actionDurations clear];
    [self startSymbolsVanish: vanishingViews];
    double vanishTotalDuration = [VIEW.actionDurations take];
    [event performSelector: @selector(eventSymbolsDidVanish:) withObject:vanishingViews afterDelay:vanishTotalDuration];
    
    
    // get the null rows and columns
    NSMutableArray* nullRowColumns = [NSMutableArray array];
    NSArray* indexPathsRepository = QueueIndexPathParser.indexPathsRepository;
    NSArray* symbolsAtContainer = QueueViewsHelper.viewsInVisualArea;
    for (NSInteger i = 0; i < symbols.count; i++) {
        SymbolView* symbol = symbols[i];
        int row = symbol.row;
        int column = symbol.column;
        [[symbolsAtContainer objectAtIndex: row] replaceObjectAtIndex: column withObject:[NSNull null]];
        [nullRowColumns addObject: [[indexPathsRepository objectAtIndex: row] objectAtIndex: column]];
    }
    
    
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

-(void) startSymbolsRollIn
{
    [self roll:linesConfigs[RollIn] config:positionsConfigs[RollIn] actionsConfig:actionsConfigs[RollIn]];
}

-(void) startSymbolsRollOut
{
    [self roll:linesConfigs[RollOut] config:positionsConfigs[RollOut] actionsConfig:actionsConfigs[RollOut]];
}

-(void) roll: (NSArray*)lines config:(NSDictionary*)config actionsConfig:(NSArray*)actionsConfig
{
    NSDictionary* linesConfig = config[LINES];
    NSDictionary* indexPathsConfig = config[INDEXPATHS];
    BOOL isBackward = [indexPathsConfig[IsBackward] boolValue];
    BOOL isColumnBase = [indexPathsConfig[IsColumnBase] boolValue];
    
    NSMutableArray* nullLocations = [NSMutableArray array];
    [IterateHelper iterateTwoDimensionArray:QueueViewsHelper.viewsRepository handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
        [nullLocations addObject:[[QueueIndexPathParser.indexPathsRepository objectAtIndex:outterIndex] objectAtIndex: innerIndex]];
        return NO;
    }];
    
    NSMutableArray* nullIndexPaths = [QueueIndexPathParser getIndexPathsIn: lines elements:nullLocations];
    
    NSArray* groupedNullIndexpaths = [QueueIndexPathParser groupTheNullIndexPaths: nullIndexPaths isNullIndexPathsBreakWhenNotCoterminous:NO isColumnBase:isColumnBase];
    NSArray* indexPaths = [QueueIndexPathParser assembleIndexPaths:lines groupedNullIndexpaths:groupedNullIndexpaths isBackward:isBackward isColumnBase:isColumnBase];
    
    
    NSMutableArray* views = [QueueViewsHelper getViewsQueues: lines indexPaths:indexPaths];
    NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
    
    // start , trigger event
    [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:views values:positions baseTimes:nil];
    
    
//    [PositionsHelper updateAdjustRowsColumnsInVisualArea: views];
}



-(void) startSymbolsVanish: (NSArray*)views
{
    [VIEW.actionExecutorManager runActionExecutors:actionsConfigs[Vanish] onObjects:views values:nil baseTimes:nil];
}



-(void) startSymbolsSqueeze: (NSArray*)nullRowColumns vanishingViews:(NSArray*)vanishingViews vanishDuration:(double)vanishDuration
{
    [self adjusts: linesConfigs[Squeeze_Adjust] config:positionsConfigs[Squeeze_Adjust] nullRowColumns:nullRowColumns actionsConfig:actionsConfigs[Squeeze_Adjust] delay:vanishDuration];
    
    [self fillIn: linesConfigs[Squeeze_FillIn] config:positionsConfigs[Squeeze_FillIn] actionsConfig:actionsConfigs[Squeeze_FillIn] vanishingViews:vanishingViews delay:vanishDuration];
}




-(void) startSymbolsAdjusts: (NSArray*)nullRowColumns delay:(double)delay
{
    [self adjusts:linesConfigs[Adjusts] config:positionsConfigs[Adjusts] nullRowColumns:nullRowColumns actionsConfig:actionsConfigs[Adjusts] delay:delay];
}

-(void) adjusts: (NSArray*)lines config:(NSDictionary*)config nullRowColumns:(NSArray*)nullRowColumns actionsConfig:(NSArray*)actionsConfig delay:(double)delay
{
    NSDictionary* linesConfig = config[LINES];
    NSDictionary* indexPathsConfig = config[INDEXPATHS];
    BOOL isBackward = [indexPathsConfig[IsBackward] boolValue];
    BOOL isColumnBase = [indexPathsConfig[IsColumnBase] boolValue];
    
    NSMutableArray* nullIndexPaths = [QueueIndexPathParser getIndexPathsIn: lines elements:nullRowColumns];
    NSArray* groupedNullIndexpaths = [QueueIndexPathParser groupTheNullIndexPaths: nullIndexPaths isNullIndexPathsBreakWhenNotCoterminous:NO isColumnBase:isColumnBase];
    NSArray* indexPaths = [QueueIndexPathParser assembleIndexPaths:lines groupedNullIndexpaths:groupedNullIndexpaths isBackward:isBackward isColumnBase:isColumnBase];
    
    
    NSMutableArray* views = [QueueViewsHelper getViewsQueues: lines indexPaths:indexPaths];
    NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
    
    NSNumber* delayNum = @(delay);
    NSMutableArray* baseTimes = [NSMutableArray array];
    for (NSArray* innerViews in views) {
        NSMutableArray* innerBaseTimes = [NSMutableArray array];
        for (int i = 0; i < innerViews.count; i++) {
            [innerBaseTimes addObject:delayNum];
        }
        [baseTimes addObject: innerBaseTimes];
    }
    
    
    [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:views values:positions baseTimes:baseTimes];
    
    
    [PositionsHelper updateAdjustRowsColumnsInVisualArea: views];
}



-(void) startSymbolsFillIn:(NSArray*)vanishingViews delay:(double)delay
{
    [self fillIn:linesConfigs[FillIn] config:positionsConfigs[FillIn] actionsConfig:actionsConfigs[FillIn] vanishingViews:vanishingViews delay:delay];
}

-(void) fillIn: (NSArray*)lines config:(NSDictionary*)config actionsConfig:(NSArray*)actionsConfig vanishingViews:(NSArray*)vanishingViews delay:(double)delay
{
    NSDictionary* linesConfig = config[LINES];
    NSDictionary* indexPathsConfig = config[INDEXPATHS];
    BOOL isBackward = [indexPathsConfig[IsBackward] boolValue];
    BOOL isColumnBase = [indexPathsConfig[IsColumnBase] boolValue];
    
    
    NSMutableArray* nullRowColumns = [PositionsHelper getIndexPathsNullInVisualAreaViews];
    NSMutableArray* nullIndexPaths = [QueueIndexPathParser getIndexPathsIn: lines elements:nullRowColumns];
    NSArray* groupedNullIndexpaths = [QueueIndexPathParser groupTheNullIndexPaths: nullIndexPaths isNullIndexPathsBreakWhenNotCoterminous:YES isColumnBase:isColumnBase];
    NSArray* indexPaths = [QueueIndexPathParser assembleIndexPaths:lines groupedNullIndexpaths:groupedNullIndexpaths isBackward:isBackward isColumnBase:isColumnBase];
    
    NSMutableArray* uselessViews = [QueueViewsHelper getUselessViews];
    for (UIView* vanishingView in vanishingViews) {
        [uselessViews removeObject: vanishingView];
    }
    
    int count = 0 ;
    NSNumber* delayNum = @(delay);
    NSMutableArray* views = [NSMutableArray array];
    NSMutableArray* baseTimes = [NSMutableArray array];
    for (NSUInteger i = 0; i < groupedNullIndexpaths.count; i++) {
        NSArray* oneGroupedNullIndexpaths = groupedNullIndexpaths[i];
        NSMutableArray* innerViews = [NSMutableArray array];
        NSMutableArray* innerBaseTimes = [NSMutableArray array];
        for (NSUInteger j = 0; j < oneGroupedNullIndexpaths.count; j++) {
            UIView* view = [uselessViews objectAtIndex:count];
            [innerViews addObject: view];
            [innerBaseTimes addObject:delayNum];
            count++;
        }
        [views addObject: innerViews];
        [baseTimes addObject: innerBaseTimes];
    }
    
    NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
    
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
    
    [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:views values:positions baseTimes:baseTimes];
    
    [PositionsHelper updateFillInRowsColumnsInVisualArea: views];
}


@end
