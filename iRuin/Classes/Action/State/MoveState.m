#import "MoveState.h"
#import "AppInterface.h"

@implementation MoveState
{
    SymbolView* touchingSymbol;
    
    NSMutableArray* engageSymbolRepository;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        engageSymbolRepository = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Override Methods

- (void)stateTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesBegan: symbol location:location];
    
    touchingSymbol = symbol;
    if (symbol) {
        if (![engageSymbolRepository containsObject: symbol]) [engageSymbolRepository addObject: symbol];
    }
}
- (void)stateTouchesMoved:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesMoved: symbol location:location];
    
    if (! symbol) return;
    
    if (! touchingSymbol) {
        touchingSymbol = symbol;
        
        if (![engageSymbolRepository containsObject: symbol]){
            [engageSymbolRepository addObject: symbol];
        }
        
        return;
    }
    
    if (touchingSymbol == symbol) {
        return;
    } else {
//        DLOG(@" ------- Gotcha -------");
        
        int abs_col = abs(touchingSymbol.column - symbol.column);
        int abs_row = abs(touchingSymbol.row - symbol.row);
        if (abs_col > 1 || abs_row > 1) {
//            DLOG(@" ------- not adjacent -------");
            // do vanish
            [self startVanishProcedure];
            return;
        }
        
        else
        
        {
            
            // the same identification
            if (touchingSymbol.prototype.identification == symbol.prototype.identification) {
                // add to engage
                if (![engageSymbolRepository containsObject: symbol]){
                    [engageSymbolRepository addObject: symbol];
                }
            }
            
            else
            
            // not the same identification
            {
//                DLOG(@"-- Not The same id ... ");
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
        if (![engageSymbolRepository containsObject: symbol]) [engageSymbolRepository addObject: symbol];
    }
    
    [self startVanishProcedure];
}
- (void)stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesCancelled: symbol location:location];
    
    touchingSymbol = nil;
}






#pragma mark - Private Methods

-(void) startVanishProcedure
{
    if (engageSymbolRepository.count >= MATCH_COUNT) {
        NSMutableArray* vanishSymbols = [SearchHelper searchMoveMatchedSymbols: engageSymbolRepository];
        DLOG(@"vanish count : %lu", (unsigned long)vanishSymbols.count);
//        [vanishSymbols exchangeObjectAtIndex:vanishSymbols.count-1 withObjectAtIndex:0];
        if (vanishSymbols.count >= MATCH_COUNT) {
            [self.effect effectStartVanish: vanishSymbols];
        }
    }
    [engageSymbolRepository removeAllObjects];
    touchingSymbol = nil;
}

@end
