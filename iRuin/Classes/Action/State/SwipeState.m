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




#define swap_swipe_minispeed (500.0)
#define swap_swipe_nimidistance (50.0)
#pragma mark - Private Methods
-(void) checkIsSwipeThenSwipe: (CGPoint)checkLocation {
    float xDistance = fabsf(checkLocation.x - startPoint.x);
    float yDistance = fabsf(checkLocation.y - startPoint.y);
    double distance = sqrt((xDistance * xDistance) + (yDistance * yDistance));
    if (distance >= swap_swipe_nimidistance) {
        isHaveCheckSwipe = YES;
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate: startTime];
        double speed = distance / interval ;
//        DLOG(@"swipe speed: %f",speed);
        if (speed > swap_swipe_minispeed) {
            SymbolView* symbol = [SearchHelper getAdjacentSymbolByDirection: touchingSymbol start:startPoint end:checkLocation];
//            DLog(@"is swipe : %@", symbol);
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
    [VIEW.actionExecutorManager runActionExecutors:[DATA config:MODE_SWIPE][@"Swipe_First_ActionExecutors"] onObjects:@[symbol] values:symbolPositions baseTimes:nil];
    swapEffectDuration += [timeCalculator takeThenClear];
    [VIEW.actionExecutorManager runActionExecutors:[DATA config:MODE_SWIPE][@"Swipe_Second_ActionExecutors"] onObjects:@[withSymbol] values:withSymbolPositions baseTimes:nil];
    swapEffectDuration += [timeCalculator takeThenClear];
    
    // update the row and column attribute , and the position in symbolsInContainer
    [PositionsHelper updateRowsColumnsInVisualArea: @[symbol, withSymbol]];
    
    // start the vanish effect
    NSMutableArray* vanishSymbols = [SearchHelper searchSwipeMatchedSymbols: symbol secondSymbol:withSymbol];
    
    if (vanishSymbols.count >= MATCH_COUNT) {
        [self.effect performSelector: @selector(effectStartVanish:) withObject:vanishSymbols afterDelay:swapEffectDuration];
        
    }
    
}

@end
