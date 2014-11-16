#import "DotsState.h"
#import "AppInterface.h"

@implementation DotsState
{
    SymbolView* touchingSymbol;
    
    
    CGFloat offsetX ;
    CGFloat offsetY ;
    
    
    NSArray* neighbourSymbols ;
    CGMutablePathRef validNeighbourAreaInContainer;
}

#pragma mark - Override Methods

-(void) stateTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesBegan:symbol location:location];
    
    if (! symbol) return;
    
    [self setTouchingSymbol:symbol location:location];
    [self setNeighbourAreaAndSymbols: symbol];
}

-(void)stateTouchesMoved:(SymbolView *)symbol location:(CGPoint)location
{
    [super stateTouchesMoved:symbol location:location];
    
    // move the touching symbol
    if(! touchingSymbol) {
        [self setTouchingSymbol:symbol location:location];
        [self setNeighbourAreaAndSymbols: symbol];
    }
    
    CGFloat x = location.x - offsetX;
    CGFloat y = location.y - offsetY;
    touchingSymbol.center = CGPointMake(x, y);
    
    if (!CGPathContainsPoint(validNeighbourAreaInContainer, NULL, location, false)) return;
    
    // exchange symbol
    SymbolView* exchangeSymbol = [self getExchangeSymbolOnMoving: touchingSymbol.center];
    if (exchangeSymbol) {
        
        // first , exchange the row column and position
        int tmpRow = exchangeSymbol.row;
        int tmpColumn = exchangeSymbol.column;
        
        exchangeSymbol.row = touchingSymbol.row;
        exchangeSymbol.column = touchingSymbol.column;
        
        touchingSymbol.row = tmpRow;
        touchingSymbol.column = tmpColumn;
        
        [self adjustSymbolPosition: exchangeSymbol config:DATA.config[@"ExchangedSymbol_ActionExecutors"]];
        
        // second , reset validNeighbourAreaInContainer & neighbourSymbols
        [self setNeighbourAreaAndSymbols: touchingSymbol];
    }
    
}


-(void) stateTouchesEnded:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesEnded:symbol location:location];
    
    if (! touchingSymbol) return;
    
    QueueTimeCalculator* timeCalculator = VIEW.actionDurations;
    [timeCalculator clear];
    [self adjustSymbolPosition: touchingSymbol config:DATA.config[@"TouchingSymbol_ActionExecutors"]];
    double effectDuration = [timeCalculator takeThenClear];
    
    // start vanish ~~~~~
    [self performSelector:@selector(startVanishProcedure) withObject:nil afterDelay:effectDuration];
    
    touchingSymbol = nil;
}

-(void) stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesCancelled:symbol location:location];
    
    if (! touchingSymbol) return;
    
    [self adjustSymbolPosition: touchingSymbol config:DATA.config[@"TouchingSymbol_ActionExecutors"]];
    
    touchingSymbol = nil;
}



#pragma mark -

-(void) adjustSymbolPosition: (SymbolView*)symbol config:(NSDictionary*)config
{
    // got to the position
    NSValue* fromValue = CGPointValue(symbol.center);
    NSValue* toValue = [[[QueuePositionsHelper positionsRepository] objectAtIndex: symbol.row] objectAtIndex:symbol.column];
    [VIEW.actionExecutorManager runActionExecutors:config onObjects:@[symbol] values:@[fromValue, toValue] baseTimes:nil];
    
    // update the row and column attribute , and the position in viewsInVisualArea
    [PositionsHelper updateRowsColumnsInVisualArea: @[symbol]];
}

-(void) setTouchingSymbol: (SymbolView*)symbol location:(CGPoint)location
{
    touchingSymbol = symbol;
    offsetX = location.x - symbol.center.x;
    offsetY = location.y - symbol.center.y;
}

-(void) setNeighbourAreaAndSymbols: (SymbolView*)symbol
{
    // validNeighbourAreaInContainer & neighbourSymbols
    CGPathRelease(validNeighbourAreaInContainer);
    validNeighbourAreaInContainer = CGPathCreateMutable();
    
    neighbourSymbols = [SearchHelper getAdjacentSymbolByDirections:symbol directions:DirectionUP|DirectionRIGHT|DirectionDOWN|DirectionLEFT];
    for (int i = 0; i < neighbourSymbols.count; i++) {
        SymbolView* symbol = [neighbourSymbols objectAtIndex: i];
        CGPathAddEllipseInRect(validNeighbourAreaInContainer, NULL, symbol.frame);
        
        VIEW.gameView.containerView.areaPathInContainer = validNeighbourAreaInContainer;
        [VIEW.gameView.containerView setNeedsDisplay];
    }
}

-(SymbolView*) getExchangeSymbolOnMoving: (CGPoint)location {
    for (SymbolView* symbol in neighbourSymbols) {
        CGPoint point = [symbol convertPoint: location fromView:[symbol superview]];
        if ([symbol isInValidArea: point]) {
            return symbol;
        }
    }
    return nil;
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
