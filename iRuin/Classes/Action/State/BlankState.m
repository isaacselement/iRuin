#import "BlankState.h"
#import "AppInterface.h"

#import "ExplodeExecutor.h"

@implementation BlankState
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
        
        NSMutableArray* vanishSymbols = [SearchHelper searchBlankMatchedSymbols: symbol];
        if (vanishSymbols) [self.effect effectStartVanish: vanishSymbols];
        // to do the explode effect ...
//        [VIEW.actionExecutorManager runActionExecutors:[DATA config:MODE_BLANK][@"Blank_Explode_ActionExecutors"] onObjects:@[symbol] values:nil baseTimes:nil];
    }
    
}
-(void) stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesCancelled:symbol location:location];
    
}

#pragma mark -

@end
