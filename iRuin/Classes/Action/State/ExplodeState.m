#import "ExplodeState.h"
#import "AppInterface.h"

#import "ExplodesExecutor.h"

@implementation ExplodeState
{
    SymbolView* touchingSymbol;
}

#pragma mark - Override Methods
-(void) stateTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesBegan:symbol location:location];
    
    touchingSymbol = symbol;
    
}
-(void) stateTouchesMoved:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesMoved:symbol location:location];
    
}
-(void) stateTouchesEnded:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesEnded:symbol location:location];
    
    if (touchingSymbol && touchingSymbol == symbol) {
        NSMutableArray* vanishSymbols = [SearchHelper searchExplodeMatchedSymbols: symbol];
        if (vanishSymbols) {
            [self.effect effectStartVanish: vanishSymbols];
        }
    }
    
}
-(void) stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesCancelled:symbol location:location];
    
}

#pragma mark -

@end
