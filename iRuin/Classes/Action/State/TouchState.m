#import "TouchState.h"
#import "AppInterface.h"

@implementation TouchState
{
    SymbolView* touchingSymbol;
}

#pragma mark - Override Methods

- (void)stateTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesBegan:symbol location:location];
    
    touchingSymbol = symbol;
}
- (void)stateTouchesEnded:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesEnded:symbol location:location];
    
    if (! symbol) return;
    // When is the same as the touched in begin
    if (touchingSymbol == symbol) {
        [self startVanishProcedure];
    }
}
- (void)stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesCancelled:symbol location:location];
    
    touchingSymbol = nil;
}


#pragma mark - Private Methods

-(void) startVanishProcedure
{
    NSMutableArray* vanishSymbols = [SearchHelper searchTouchMatchedSymbols: touchingSymbol];
    [self.effect effectStartVanish: vanishSymbols];
}

@end
