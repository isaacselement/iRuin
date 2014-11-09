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
    
    if (touchingSymbol == symbol) {
        
        if (!waitingSymbol) {
            
            waitingSymbol = symbol;
            
        } else {
            
            [self startExchangeEffectAndRestoreStates];
            
        }
        
    } else {
        
        waitingSymbol = nil;
        touchingSymbol = nil;
        
    }
}

-(void) stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesCancelled:symbol location:location];
    
    waitingSymbol = nil;
    touchingSymbol = nil;
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
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeRemoved;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [symbol.layer removeAnimationForKey:@"changeTextTransition"];
    [symbol.layer addAnimation:animation forKey:@"changeTextTransition"];
    
    [withSymbol.layer removeAnimationForKey:@"changeTextTransition"];
    [withSymbol.layer addAnimation:animation forKey:@"changeTextTransition"];
    
    // TODO. Apply the effect ...
    int tempId = symbol.identification;
    symbol.identification = withSymbol.identification;
    withSymbol.identification = tempId;
}

@end
