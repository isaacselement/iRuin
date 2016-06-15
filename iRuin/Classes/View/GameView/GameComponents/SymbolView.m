#import "SymbolView.h"
#import "AppInterface.h"

@implementation SymbolView
{
    GradientImageView* symbolImageView;
    
    
    CGMutablePathRef validAreaCGPath;
    
    
//    UILabel* rowLabel;
//    UILabel* columnLabel;
}


@synthesize row;
@synthesize column;
@synthesize isIntersectionInVanish;

//@synthesize containerLayer;



#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        containerLayer = [CATransformLayer layer];
//        [self.layer addSublayer: containerLayer];
        
        self.score = 1.0;
        
        symbolImageView = [[GradientImageView alloc] initWithFrame: self.bounds];
        symbolImageView.userInteractionEnabled = NO;
        [self addSubview: symbolImageView];
        
        
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
    symbolImageView.frame = self.bounds;
//    containerLayer.frame = self.bounds;
}

-(NSString*) description {
    return [NSString stringWithFormat: @"[[%s] %p (%d,%d) ,id: %d]  (%.1f, %.1f)", object_getClassName(self), self, row, column, self.identification, [self centerX], [self centerY]];
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isPointInside = [super pointInside:point withEvent:event];

    if (row == -1 || column == -1) {
        isPointInside = NO;
    }
    
    return isPointInside;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//-(void)drawRect:(CGRect)rect
//{
//    [self drawValidArea:validAreaCGPath];
//}

#pragma mark - Public Methods

-(void) restore
{
    row = -1;
    column = -1;
    isIntersectionInVanish = NO;
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

-(void)setIdentification: (int)identification
{
    _identification = identification;

    CAGradientLayer* layer = (CAGradientLayer*)symbolImageView.layer;
    layer.locations = nil;
    layer.colors = nil;
    
    [SymbolView setSymbolIdentification: identification symbol:self];
}


#pragma mark - Class Methods

+(void) setSymbolIdentification: (int)identification symbol:(SymbolView*)symbol
{
    int index = identification - 1;     // HERE!!!!! identification to index
    NSDictionary* configs = [ConfigHelper getSymbolsPorperties];
    NSDictionary* specification = [ConfigHelper getNodeConfig:configs index:index];
    [ACTION.gameEffect designateValuesActionsTo:symbol config:specification];
}

+(int) getOneRandomSymbolIdentification
{
    int count = [ConfigHelper getSymbolsIdentificationsCount];
    int index = arc4random() % count;
    int identification = index + 1;     // HERE!!!!! index to identification
    return identification;
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

@end
