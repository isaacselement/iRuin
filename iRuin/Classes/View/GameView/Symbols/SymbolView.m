#import "SymbolView.h"
#import "AppInterface.h"

@implementation SymbolView
{
    CGMutablePathRef validAreaCGPath;
    
//    UILabel* rowLabel;
//    UILabel* columnLabel;
}

@synthesize row;
@synthesize column;

@synthesize containerLayer;



#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        containerLayer = [CATransformLayer layer];
        [self.layer addSublayer: containerLayer];
        [self restore];
        
//        rowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
//        columnLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 15, 15)];
//        
//        [self addSubview: rowLabel];
//        [self addSubview: columnLabel];
    }
    return self;
}

//-(void)setRow:(int)rowObj
//{
//    row = rowObj;
//    rowLabel.text = [NSString stringWithFormat:@"%d",row];
//}
//
//-(void)setColumn:(int)columnObj
//{
//    column = columnObj;
//    columnLabel.text = [NSString stringWithFormat:@"%d", column];
//}

- (void)dealloc {
    CGPathRelease(validAreaCGPath);
    validAreaCGPath = nil;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    containerLayer.frame = self.bounds;
}

-(NSString*) description {
    return [NSString stringWithFormat: @"[[%s]%p(%d,%d) ,%@]", object_getClassName(self), self, row, column, self.prototype];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//-(void)drawRect:(CGRect)rect
//{
//    [self drawValidArea:validAreaCGPath];
//}

#pragma mark -

-(void)setPrototype:(Symbol *)prototype
{
    // do the appearance stuff
    _prototype = prototype;
    self.backgroundColor = prototype.color;
}

#pragma mark - Public Methods
-(void) vanish
{
    [self restore];
}

-(void) restore
{
    row = -1;
    column = -1;
    self.center = VIEW.frame.blackPoint;
    [self.layer removeAllAnimations];
}

-(void) setValidArea: (CGRect)rect
{
    if (validAreaCGPath) {
        CGPathRelease(validAreaCGPath);
        validAreaCGPath = nil;
    }
    validAreaCGPath = CGPathCreateMutable();
    CGPathAddEllipseInRect(validAreaCGPath, NULL, rect);
}

-(BOOL) isInValidArea: (CGPoint)location
{
    return CGPathContainsPoint(validAreaCGPath, NULL, location, true);
}


#pragma mark - Private Methods
// call it in drawRect: methods
-(void) drawValidArea: (CGMutablePathRef)path
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 0);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
}

-(void) addEllipseInRectWithAnimation {
    CGPoint ellipseOrigin = CGPointMake(0, 0);
    CGSize ellipseSize = self.bounds.size;// CGSizeMake(200, 100);
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect rect = (CGRect){CGPointZero, ellipseSize};
    CGPathAddEllipseInRect(path, NULL, rect);

    CAShapeLayer *ellipseLayer = [CAShapeLayer layer];
    ellipseLayer.frame = (CGRect){ellipseOrigin, ellipseSize};
    ellipseLayer.path = path;
    ellipseLayer.strokeColor = [UIColor blackColor].CGColor;
    ellipseLayer.fillColor = nil; // transparent inside

    CFRelease(path);

    // I tested it in the viewDidLoad method of a view controller
    [self.layer addSublayer:ellipseLayer];

    CABasicAnimation *drawAnim = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnim.duration = 5.0;
    drawAnim.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnim.toValue = [NSNumber numberWithFloat:1.0f];
    [ellipseLayer addAnimation:drawAnim forKey:@"strokeEnd"];
}


//CABasicAnimation *diagonalAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
//// set the duration of the animation - a float
//[diagonalAnimation setDuration: 0.5];
//// set the animation's "toValue" which MUST be wrapped in an NSValue instance (except special cases such as colors)
//diagonalAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(symbol.containerLayer.transform, CATransform3DRotate(CATransform3DIdentity, M_PI/2, -1, 1, 0))];
//// finally, apply the animation
//[symbol.containerLayer addAnimation:diagonalAnimation forKey:@"arbitraryKey"];


@end




