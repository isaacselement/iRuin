#import "ContainerView.h"
#import "AppInterface.h"


@implementation ContainerView



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    [self touchesBegan:location event:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    [self touchesMoved:location event:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    [self touchesEnded:location event:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    [self touchesCancelled:location event:event];
}




#pragma mark - Public Methods

- (void)touchesBegan:(CGPoint)location event:(UIEvent *)event
{
    SymbolView* symbol = [self getSymbolView: location event:event];
    
    [ACTION.currentEvent eventTouchesBegan: symbol location:location];
}

- (void)touchesMoved:(CGPoint)location event:(UIEvent *)event
{
    SymbolView* symbol = [self getSymbolView: location event:event];
    
    [ACTION.currentEvent eventTouchesMoved: symbol location:location];
}

- (void)touchesEnded:(CGPoint)location event:(UIEvent *)event
{
    SymbolView* symbol = [self getSymbolView: location event:event];
    
    [ACTION.currentEvent eventTouchesEnded: symbol location:location];
}

- (void)touchesCancelled:(CGPoint)location event:(UIEvent *)event
{
    SymbolView* symbol = [self getSymbolView: location event:event];
    
    [ACTION.currentEvent eventTouchesCancelled: symbol location:location];
}




#pragma mark -

-(SymbolView*) getSymbolView: (CGPoint)location event:(UIEvent*)event
{
    // hit test, may nil , or may container itself
    SymbolView* symbol = (SymbolView*)[self hitTest: location withEvent:event];
    
    if (! symbol) {
        return nil;
    }
    
    if ((id)symbol == self) {
        return nil;
    }
    
    if (![symbol isInValidArea:[self convertPoint: location toView:symbol]]) {
        return nil;
    }
    
    return symbol;
}

@end
