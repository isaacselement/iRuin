#import "RouteState.h"
#import "AppInterface.h"

@implementation RouteState
{
    SymbolView* touchingSymbol;
    
    NSMutableArray* engageSymbols;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        engageSymbols = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Override Methods

- (void)stateTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesBegan: symbol location:location];
    
    touchingSymbol = symbol;
    if (symbol) {
        if (![engageSymbols containsObject: symbol]) [engageSymbols addObject: symbol];
    }
}
- (void)stateTouchesMoved:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesMoved: symbol location:location];
    
    if (! symbol) return;
    
    if (! touchingSymbol) {
        touchingSymbol = symbol;
        
        if (![engageSymbols containsObject: symbol]){
            [engageSymbols addObject: symbol];
        }
        
        return;
    }
    
    if (touchingSymbol == symbol) {
        return;
    } else {
        
        int abs_col = abs(touchingSymbol.column - symbol.column);
        int abs_row = abs(touchingSymbol.row - symbol.row);
        if (abs_col > 1 || abs_row > 1) {
            // do vanish
            [self startVanishProcedure];
            return;
        }
        
        else
        
        {
            
            // the same identification
            if (touchingSymbol.identification == symbol.identification) {
                // add to engage
                if (![engageSymbols containsObject: symbol]){
                    [engageSymbols addObject: symbol];
                }
            }
            
            else
            
            // not the same identification
            {
                // do vanish
                [self startVanishProcedure];
                return;
                
            }
            
            
        }
        
        
        
        touchingSymbol = symbol;
    }
    
}
- (void)stateTouchesEnded:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesEnded: symbol location:location];
    
    touchingSymbol = nil;
    if (symbol) {
        if (![engageSymbols containsObject: symbol]) [engageSymbols addObject: symbol];
    }
    
    [self startVanishProcedure];
}
- (void)stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesCancelled: symbol location:location];
    
    touchingSymbol = nil;
}


#pragma mark - Private Methods

- (void)startVanishProcedure
{
    NSMutableArray* vanishSymbols = [SearchHelper searchRouteMatchedSymbols:engageSymbols matchCount:MATCH_COUNT];
    [engageSymbols removeAllObjects];
    touchingSymbol = nil;
    [self stateStartVanishSymbols:vanishSymbols];
}

@end
