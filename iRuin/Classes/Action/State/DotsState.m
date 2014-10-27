#import "DotsState.h"
#import "AppInterface.h"

@implementation DotsState
{
    SymbolView* touchingSymbol; // the last symbol
    
    SymbolView* waitingSymbol;  // the first symbol
}

#pragma mark - Override Methods

-(void) stateTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesBegan:symbol location:location];
    
    if (! symbol) return;
    
    touchingSymbol = symbol;
    
    // do the touching effect ...
    
}

-(void) stateTouchesEnded:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesEnded:symbol location:location];
    
    if (! symbol) return;
    
    if (touchingSymbol && touchingSymbol != symbol) {
        [self startExchangeEffectAndRestoreStates];
        
    } else if (touchingSymbol == symbol) {

        if (!waitingSymbol) {
            waitingSymbol = symbol;
            
        } else {
            [self startExchangeEffectAndRestoreStates];
        }


    }
}

-(void) stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesCancelled:symbol location:location];
    
}



#pragma mark -

-(void) startExchangeEffectAndRestoreStates
{
    [self exchange: waitingSymbol with:touchingSymbol];
    
    // vanish effect
    NSMutableArray* vanishSymbols = [SearchHelper searchDotsMatchedSymbols: waitingSymbol secondSymbol:touchingSymbol];
    if (vanishSymbols.count >= MATCH_COUNT) {
        [self.effect effectStartVanish: vanishSymbols];
    }
    
    // restore states
    waitingSymbol = nil;
    touchingSymbol = nil;
}

-(void) exchange: (SymbolView*)symbol with:(SymbolView*)withSymbol
{
    // TODO. Apply the effect ...
    NSString* temp = symbol.name;
    symbol.name = withSymbol.name;
    withSymbol.name = temp;
}

@end
