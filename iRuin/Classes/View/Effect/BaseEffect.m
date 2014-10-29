#import "BaseEffect.h"
#import "AppInterface.h"


@implementation BaseEffect

@synthesize event;


#pragma mark - Subclass Override Methods
- (void)effectInitialize
{
    
}
- (void)effectTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    
}
- (void)effectTouchesMoved:(SymbolView*)symbol location:(CGPoint)location
{
    
}
- (void)effectTouchesEnded:(SymbolView*)symbol location:(CGPoint)location
{
    
}
- (void)effectTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    
}




#pragma mark - Public Methods
-(void) effectStartRollIn
{
//    DLOG(@"effect - effectStartRollIn");
    [event performSelector:@selector(eventSymbolsWillRollIn) withObject:nil];
    
    [VIEW.actionDurations clear];
    [self startSymbolsRollIn];
    double totalDuration = [VIEW.actionDurations take];
    
    [event performSelector:@selector(eventSymbolsDidRollIn) withObject:nil afterDelay:totalDuration];
}

-(void) effectStartRollOut
{
    //    DLOG(@"effect - effectStartRollOut");
    [event performSelector:@selector(eventSymbolsWillRollOut) withObject:nil];
    
    [VIEW.actionDurations clear];
    [self startSymbolsRollOut];
    double totalDuration = [VIEW.actionDurations take];
    
    [event performSelector:@selector(eventSymbolsDidRollOut) withObject:nil afterDelay:totalDuration];
}


-(void)effectStartVanish: (NSMutableArray*)symbols
{
//    DLOG(@"effect - effectStartVanish");
    NSMutableArray* views = [ArrayHelper eliminateDuplicates: symbols];
    [event eventSymbolsWillVanish: views];
    
    NSArray* actionsConfig = DATA.config[@"SYMBOLS_ActionExecutors"][@"Vanish_ActionExecutors"];
    
    [VIEW.actionDurations clear];
    [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:views values:nil baseTimes:nil];
    double totalDuration = [VIEW.actionDurations take];
    
    [event performSelector: @selector(eventSymbolsDidVanish:) withObject:views afterDelay:totalDuration];
}

-(void) effectStartAdjusts: (NSArray*)nullRowColumns
{
//    DLOG(@"effect - effectStartAdjusts");
    [VIEW.actionDurations clear];
    [self startSymbolsAdjusts: nullRowColumns];
    double totalDuration = [VIEW.actionDurations take];
    
    [event performSelector: @selector(eventSymbolsDidAdjusts) withObject:nil afterDelay:totalDuration];
}

-(void) effectStartFillIn
{
//    DLOG(@"effect - effectStartFillIn");
    [VIEW.actionDurations clear];
    [self startSymbolsFillIn];
    double totalDuration = [VIEW.actionDurations take];
    
    [event performSelector: @selector(eventSymbolsDidFillIn) withObject:nil afterDelay:totalDuration];
}


-(void) effectStartSqueeze: (NSArray*)nullRowColumns
{
//    DLOG(@"effect - effectStartSqueeze");
    [VIEW.actionDurations clear];
    [self startSymbolsSqueeze: nullRowColumns];
    double totalDuration = [VIEW.actionDurations take];
    
    [event performSelector: @selector(eventSymbolsDidSqueeze) withObject:nil afterDelay:totalDuration];
}


#pragma mark - Private Methods

-(void) startSymbolsRollIn
{
    // start roll in effect
    NSArray* lines = DATA.config[@"VISUAL.POSITIONS"][@"RollIn"];
    NSDictionary* config = DATA.config[@"CONFIG.POSITIONS"][@"RollIn"];
    NSArray* actionsConfig = DATA.config[@"SYMBOLS_ActionExecutors"][@"RollIn_ActionExecutors"];
    [self roll:lines config:config actionsConfig:actionsConfig];
}
-(void) startSymbolsRollOut
{
    // start roll in effect
    NSArray* lines = DATA.config[@"VISUAL.POSITIONS"][@"RollOut"];
    NSDictionary* config = DATA.config[@"CONFIG.POSITIONS"][@"RollOut"];
    NSArray* actionsConfig = DATA.config[@"SYMBOLS_ActionExecutors"][@"RollOut_ActionExecutors"];
    [self roll:lines config:config actionsConfig:actionsConfig];
}

-(void) roll: (NSArray*)lines config:(NSDictionary*)config actionsConfig:(NSArray*)actionsConfig
{
    NSDictionary* linesConfig = config[@"LINES"];
    NSDictionary* indexPathsConfig = config[@"INDEXPATHS"];
    
    NSMutableArray* nullLocations = [NSMutableArray array];
    [IterateHelper iterateTwoDimensionArray:QueueViewsHelper.viewsRepository handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
        [nullLocations addObject:[[QueueIndexPathParser.indexPathsRepository objectAtIndex:outterIndex] objectAtIndex: innerIndex]];
        return NO;
    }];
    
    NSMutableArray* nullIndexPaths = [QueueIndexPathParser getIndexPathsIn: lines elements:nullLocations];
    
    BOOL isBackward = [indexPathsConfig[@"isBackward"] boolValue];
    BOOL isColumnBase = [indexPathsConfig[@"isColumnBase"] boolValue];
    NSArray* groupedNullIndexpaths = [QueueIndexPathParser groupTheNullIndexPaths: nullIndexPaths isNullIndexPathsBreakWhenNotCoterminous:NO isColumnBase:isColumnBase];
    NSArray* indexPaths = [QueueIndexPathParser assembleIndexPaths:lines groupedNullIndexpaths:groupedNullIndexpaths isBackward:isBackward isColumnBase:isColumnBase];
    
    
    NSMutableArray* views = [QueueViewsHelper getViewsQueues: lines indexPaths:indexPaths];
    NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
    
    // start , trigger event
    [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:views values:positions baseTimes:nil];
}

-(void) startSymbolsAdjusts: (NSArray*)nullRowColumns
{
    // start adjusts effect
    NSArray* lines = DATA.config[@"VISUAL.POSITIONS"][@"Adjusts"];
    NSDictionary* config = DATA.config[@"CONFIG.POSITIONS"][@"Adjusts"];
    [self adjusts:lines config:config nullRowColumns:nullRowColumns actionsConfig:DATA.config[@"SYMBOLS_ActionExecutors"][@"Adjusts_ActionExecutors"]];
}

-(void) adjusts: (NSArray*)lines config:(NSDictionary*)config nullRowColumns:(NSArray*)nullRowColumns actionsConfig:(NSArray*)actionsConfig
{
    NSDictionary* linesConfig = config[@"LINES"];
    NSDictionary* indexPathsConfig = config[@"INDEXPATHS"];
    
    NSMutableArray* nullIndexPaths = [QueueIndexPathParser getIndexPathsIn: lines elements:nullRowColumns];
    
    BOOL isBackward = [indexPathsConfig[@"isBackward"] boolValue];
    BOOL isColumnBase = [indexPathsConfig[@"isColumnBase"] boolValue];
    NSArray* groupedNullIndexpaths = [QueueIndexPathParser groupTheNullIndexPaths: nullIndexPaths isNullIndexPathsBreakWhenNotCoterminous:NO isColumnBase:isColumnBase];
    NSArray* indexPaths = [QueueIndexPathParser assembleIndexPaths:lines groupedNullIndexpaths:groupedNullIndexpaths isBackward:isBackward isColumnBase:isColumnBase];
    
    
    NSMutableArray* views = [QueueViewsHelper getViewsQueues: lines indexPaths:indexPaths];
    NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
    
    
    [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:views values:positions baseTimes:nil];
    
    
    [PositionsHelper updateAdjustRowsColumnsInVisualArea: views];
}

-(void) startSymbolsFillIn
{
    // start fill in effect
    NSArray* lines = DATA.config[@"VISUAL.POSITIONS"][@"FillIn"];
    NSDictionary* config = DATA.config[@"CONFIG.POSITIONS"][@"FillIn"];
    [self fillIn:lines config:config actionsConfig:DATA.config[@"SYMBOLS_ActionExecutors"][@"FillIn_ActionExecutors"]];
}

-(void) fillIn: (NSArray*)lines config:(NSDictionary*)config actionsConfig:(NSArray*)actionsConfig
{
    NSDictionary* linesConfig = config[@"LINES"];
    NSDictionary* indexPathsConfig = config[@"INDEXPATHS"];
    
    
    NSMutableArray* nullRowColumns = [PositionsHelper getIndexPathsNullInVisualAreaViews];
    NSMutableArray* nullIndexPaths = [QueueIndexPathParser getIndexPathsIn: lines elements:nullRowColumns];
    
    BOOL isBackward = [indexPathsConfig[@"isBackward"] boolValue];
    BOOL isColumnBase = [indexPathsConfig[@"isColumnBase"] boolValue];
    NSArray* groupedNullIndexpaths = [QueueIndexPathParser groupTheNullIndexPaths: nullIndexPaths isNullIndexPathsBreakWhenNotCoterminous:YES isColumnBase:isColumnBase];
    NSArray* indexPaths = [QueueIndexPathParser assembleIndexPaths:lines groupedNullIndexpaths:groupedNullIndexpaths isBackward:isBackward isColumnBase:isColumnBase];
    NSMutableArray* views = [QueueViewsHelper getReuseableViewsQueuesByGroupedNullIndexpaths:groupedNullIndexpaths];
    NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
    
    for (int i = 0; i < views.count; i++) {
        NSMutableArray* innverViews = [views objectAtIndex: i];
        for (int j = 1; j < innverViews.count; j++) {
            [positions[i] insertObject:positions[i][0] atIndex:0];
        }
    }
    
    [IterateHelper iterateTwoDimensionArray: views handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
        SymbolView* symbol = (SymbolView*)obj;
        symbol.name = ACTION.gameState.oneRandomSymbolName;
        return NO;
    }];
    
    [VIEW.actionExecutorManager runActionExecutors:actionsConfig onObjects:views values:positions baseTimes:nil];
    
    
    [PositionsHelper updateFillInRowsColumnsInVisualArea: views];
}

-(void) startSymbolsSqueeze: (NSArray*)nullRowColumns
{
    NSArray* linesAdjust = DATA.config[@"VISUAL.POSITIONS"][@"Squeeze.Adjust"];
    NSDictionary* configAdjust = DATA.config[@"CONFIG.POSITIONS"][@"Squeeze.Adjust"];
    [self adjusts: linesAdjust config:configAdjust nullRowColumns:nullRowColumns actionsConfig:DATA.config[@"SYMBOLS_ActionExecutors"][@"Squeeze.Adjust_ActionExecutors"]];
    
    NSArray* linesFillIn = DATA.config[@"VISUAL.POSITIONS"][@"Squeeze.FillIn"];
    NSDictionary* configFillIn = DATA.config[@"CONFIG.POSITIONS"][@"Squeeze.FillIn"];
    [self fillIn: linesFillIn config:configFillIn actionsConfig:DATA.config[@"SYMBOLS_ActionExecutors"][@"Squeeze.FillIn_ActionExecutors"]];
}

@end
