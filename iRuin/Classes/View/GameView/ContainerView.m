#import "ContainerView.h"
#import "AppInterface.h"

@interface ContainerView ()

@property (strong, nonatomic) NSArray* testPath;

@end

@implementation ContainerView


/// -------- Test ---------
//-(void)drawRect:(CGRect)rect
//{
//    if (! self.testPath) return;
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextClearRect(context, rect);
//    for (UIBezierPath* pathObj in self.testPath) {
//        CGPathRef path = pathObj.CGPath;
//        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
//        CGContextSetLineWidth(context, 1);
//        CGContextAddPath(context, path);
//        CGContextStrokePath(context);
//    }
//}

-(void)setTestPath:(NSArray*)testPath
{
    _testPath = testPath;
    [self setNeedsDisplay];
}
/// -------- Test ---------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    
    /// -------- Test ---------
//    ContainerView* containerView = VIEW.gameView.containerView;
//    NSMutableArray* array = [NSMutableArray array];
//    for (int i = 0; i < 10; i++) {
//        UIBezierPath* path = [ExplodesExecutor pathFromPoint:location];
//        [array addObject: path];
//    }
//    containerView.testPath = array;
//    return;
    /// -------- Test ---------
    
    
    SymbolView* symbol = [self getSymbolView: location event:event];
    
    [ACTION.currentEvent eventTouchesBegan: symbol location:location];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    
    SymbolView* symbol = [self getSymbolView: location event:event];
    
    [ACTION.currentEvent eventTouchesMoved: symbol location:location];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    
    SymbolView* symbol = [self getSymbolView: location event:event];
    
    [ACTION.currentEvent eventTouchesEnded: symbol location:location];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    
    SymbolView* symbol = [self getSymbolView: location event:event];
    
    [ACTION.currentEvent eventTouchesCancelled: symbol location:location];
}


#pragma mark -

-(SymbolView*) getSymbolView: (CGPoint)location event:(UIEvent*)event
{
    SymbolView* symbol = (SymbolView*)[self hitTest: location withEvent:event];
    if ((id)symbol == self || ![symbol isInValidArea:[self convertPoint: location toView:symbol]]) {
        symbol = nil;
    }
    return symbol;
}

@end
