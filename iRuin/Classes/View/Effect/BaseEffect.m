#import "BaseEffect.h"
#import "AppInterface.h"


typedef NSArray*(^ViewsInRepositoryPositionsHandler)(NSArray* lines, NSArray* indexPaths, NSArray* groupedNullIndexpaths, NSDictionary* linesConfig, NSArray* vanishingViews);

@implementation BaseEffect
{
    NSDictionary* linesConfigs;
    NSDictionary* actionsConfigs;
    NSDictionary* positionsConfigs;
    
    ViewsInRepositoryPositionsHandler rollOutViewsInRepositoryPositionsHandler;
    ViewsInRepositoryPositionsHandler rollInViewsInRepositoryPositionsHandler;
    ViewsInRepositoryPositionsHandler adjustViewsInVisualPositionsHandler;
    ViewsInRepositoryPositionsHandler fillInViewsPositionsHandler;

}

@synthesize event;


- (instancetype)init
{
    self = [super init];
    if (self) {
        
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
        
        rollOutViewsInRepositoryPositionsHandler = ^NSArray *(NSArray *lines, NSArray *indexPaths, NSArray* groupedNullIndexpaths, NSDictionary *linesConfig, NSArray* vanishingViews) {
            NSMutableArray* viewsInVisualArea = [PositionsHelper getViewsInContainerInVisualArea];
            NSMutableArray* views = [QueueViewsHelper getViewsQueuesIn:viewsInVisualArea lines:lines indexPaths:indexPaths];
            NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
            return @[views, positions];
        };
        
        adjustViewsInVisualPositionsHandler = ^NSArray *(NSArray *lines, NSArray *indexPaths, NSArray* groupedNullIndexpaths, NSDictionary *linesConfig, NSArray* vanishingViews) {
            NSMutableArray* views = [QueueViewsHelper getViewsQueuesIn:QueueViewsHelper.viewsInVisualArea lines:lines indexPaths:indexPaths];
            NSMutableArray* positions = [QueuePositionsHelper getPositionsQueues: lines indexPaths:indexPaths linesConfig:linesConfig];
            return @[views, positions];
        };
        
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
                    [symbol.superview bringSubviewToFront: symbol];
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
    return self;
}



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
    [VIEW.actionDurations clear];
    [self startSymbolsRollIn];
    double totalDuration = [VIEW.actionDurations take];
    [event eventSymbolsWillRollIn];                     // for filter the symbols
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
    // get the null rows and columns
    NSArray* symbolsAtContainer = QueueViewsHelper.viewsInVisualArea;
    for (NSInteger i = 0; i < symbols.count; i++) {
        SymbolView* symbol = symbols[i];
        
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
    
    NSMutableArray* vanishingViews = [ArrayHelper eliminateDuplicates: symbols];
    [VIEW.actionDurations clear];
    [self startSymbolsVanish: vanishingViews];
    double vanishTotalDuration = [VIEW.actionDurations take];
    [event eventSymbolsWillVanish: vanishingViews];
    [event performSelector: @selector(eventSymbolsDidVanish:) withObject:vanishingViews afterDelay:vanishTotalDuration];
    
    
    if ([DATA.config[Squeeze] boolValue]){
        
        [VIEW.actionDurations clear];
        [self startSymbolsSqueeze:vanishingViews vanishDuration:vanishTotalDuration];
        double squeezeTotalDuration = [VIEW.actionDurations take];
        [event eventSymbolsWillSqueeze];
        [event performSelector: @selector(eventSymbolsDidSqueeze) withObject:nil afterDelay:squeezeTotalDuration];
        
    } else {

        [VIEW.actionDurations clear];
        [self startSymbolsAdjusts:vanishingViews delay:vanishTotalDuration];
        double adjustTotalDuration = [VIEW.actionDurations take];
        [event eventSymbolsWillAdjusts];
        [event performSelector: @selector(eventSymbolsDidAdjusts) withObject:nil afterDelay:adjustTotalDuration];
        

        [VIEW.actionDurations clear];
        [self startSymbolsFillIn: vanishingViews delay:(vanishTotalDuration + adjustTotalDuration)];
        double filInTotalDuration = [VIEW.actionDurations take];
        [event eventSymbolsWillFillIn];
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
