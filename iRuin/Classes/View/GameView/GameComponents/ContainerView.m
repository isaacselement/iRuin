#import "ContainerView.h"
#import "AppInterface.h"


@implementation ContainerView


//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextClearRect(context, rect);
//
//    
//    [[UIColor whiteColor] set];
//    CGContextSetFillColor(context, CGColorGetComponents([[UIColor whiteColor] CGColor]));
//
//    
//    CGPathRef areaPathInContainer = self.areaPathInContainer;
//    if (areaPathInContainer) {
//        CGContextSetLineWidth(context, 0);
//        CGContextAddPath(context, areaPathInContainer);
//        CGContextFillPath(context);
//    }
//}


#pragma mark - Override Methods

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
    
    [ACTION.modeEvent eventTouchesBegan: symbol location:location];
}

- (void)touchesMoved:(CGPoint)location event:(UIEvent *)event
{
    SymbolView* symbol = [self getSymbolView: location event:event];
    
    [ACTION.modeEvent eventTouchesMoved: symbol location:location];
}

- (void)touchesEnded:(CGPoint)location event:(UIEvent *)event
{
    SymbolView* symbol = [self getSymbolView: location event:event];
    
    [ACTION.modeEvent eventTouchesEnded: symbol location:location];
}

- (void)touchesCancelled:(CGPoint)location event:(UIEvent *)event
{
    SymbolView* symbol = [self getSymbolView: location event:event];
    
    [ACTION.modeEvent eventTouchesCancelled: symbol location:location];
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


#pragma mark - Just for Development

#ifdef DEBUG

- (instancetype)init___
{
    self = [super init];
    if (self) {
        [self addTapAction];
    }
    return self;
}

- (void)addTapAction
{
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.numberOfTapsRequired = 2;
    [self addGestureRecognizer: tap];
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.numberOfTapsRequired = 3;
    [self addGestureRecognizer: tap];
}

- (void)tapAction:(UITapGestureRecognizer*)tap
{
    if (tap.numberOfTapsRequired == 2) {
        
        CGPoint location = [tap locationInView: self];
        SymbolView* symbol = [self getSymbolView: location event:nil];
        symbol.identification = 1;
        
    } else if (tap.numberOfTapsRequired == 3) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
         NSMutableArray* vanishSymbols = [SearchHelper searchMatchedInAllLines: MATCH_COUNT];
        [ACTION.modeState stateStartVanishSymbols: vanishSymbols];
#pragma clang diagnostic pop
        
    }
}

#endif

@end