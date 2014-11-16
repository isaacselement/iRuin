#import "SwipeState.h"
#import "AppInterface.h"

@implementation SwipeState
{
    SymbolView* touchingSymbol; // firstSymbol;
    
    
    NSDate* startTime;
    CGPoint startPoint;
    BOOL isHaveCheckSwipe;
    
    
    SymbolView* secondSymbol;
}

#pragma mark - Override Methods
- (void)stateTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesBegan:symbol location:location];
    
    
    startTime = [NSDate date];
    startPoint = location;
    isHaveCheckSwipe = NO;
    
    
    if (! touchingSymbol) {
        touchingSymbol = symbol;
    } else {
        secondSymbol = symbol;
    }
    
}
- (void)stateTouchesMoved:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesMoved:symbol location:location];
    
    if (! isHaveCheckSwipe) {
        [self checkIsSwipeThenSwipe: location];
    }
}
- (void)stateTouchesEnded:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesEnded:symbol location:location];
    
    
    if (touchingSymbol && secondSymbol) {
        
        // the same symbol or not . cause can move finger to other symbols
        if (symbol == secondSymbol) {
            
            // Touch the same symbol, cancel it
            if (touchingSymbol == secondSymbol) {
                DLog(@"Do the cancel effect ");
            } else {
                
                int abs_col = abs(touchingSymbol.column - secondSymbol.column);
                int abs_row = abs(touchingSymbol.row - secondSymbol.row);
                
                if (abs_col > 1 || abs_row > 1 || (abs_row == 1 && abs_col == 1) ) {
                    DLOG(@"Not adjacent");
                } else {
                    [self swipe: touchingSymbol with:secondSymbol];
                }
                
                
            }
            
            
        }
        
        [self restoreExistingState];
    }
}
- (void)stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesCancelled:symbol location:location];
    
    [self restoreExistingState];
}




#pragma mark - 


-(void) restoreExistingState
{
    touchingSymbol = nil;
    secondSymbol = nil;
}




#define swap_swipe_minispeed (200.0)
#define swap_swipe_nimidistance (25.0)
#pragma mark - Private Methods
-(void) checkIsSwipeThenSwipe: (CGPoint)checkLocation {
    float xDistance = fabsf(checkLocation.x - startPoint.x);
    float yDistance = fabsf(checkLocation.y - startPoint.y);
    double distance = sqrt((xDistance * xDistance) + (yDistance * yDistance));
    if (distance >= swap_swipe_nimidistance) {
        isHaveCheckSwipe = YES;
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate: startTime];
        double speed = distance / interval ;
        if (speed > swap_swipe_minispeed) {
            SymbolView* symbol = [SearchHelper getAdjacentSymbolByDirection: touchingSymbol start:startPoint end:checkLocation];
            // do swipe
            [self swipe: touchingSymbol with:symbol];
            
            // restore existing state
            [self restoreExistingState];
        }
    }
}







-(void) swipe: (SymbolView*)symbol with:(SymbolView*)withSymbol
{
    if (! symbol || ! withSymbol) return;
    
    double swapEffectDuration = 0;
    QueueTimeCalculator* timeCalculator = VIEW.actionDurations;
    
    NSArray* symbolPositions = @[CGPointValue(symbol.center),CGPointValue(withSymbol.center)];
    NSArray* withSymbolPositions = @[CGPointValue(withSymbol.center),CGPointValue(symbol.center)];
    
    [timeCalculator clear];
    [VIEW.actionExecutorManager runActionExecutors:DATA.config[@"Swipe_First_ActionExecutors"] onObjects:@[symbol] values:symbolPositions baseTimes:nil];
    swapEffectDuration += [timeCalculator takeThenClear];
    [VIEW.actionExecutorManager runActionExecutors:DATA.config[@"Swipe_Second_ActionExecutors"] onObjects:@[withSymbol] values:withSymbolPositions baseTimes:nil];
    swapEffectDuration += [timeCalculator takeThenClear];
    
    // update the row and column attribute , and the position in viewsInVisualArea
    [PositionsHelper updateRowsColumnsInVisualArea: @[symbol, withSymbol]];
    
    // start the vanish effect
    [self performSelector:@selector(startVanishProcedure) withObject:nil afterDelay:swapEffectDuration];
    
}





#pragma mark - Private Methods

-(void) startVanishProcedure
{
    // start the vanish effect
    NSMutableArray* vanishSymbols = [SearchHelper searchMatchedInAllLines: MATCH_COUNT];
    if (vanishSymbols.count >= MATCH_COUNT) {
        [self.effect effectStartVanish: vanishSymbols];
    }
    
}





@end
