#import "SeparateSymbolView.h"
#import "AppInterface.h"

@implementation SeparateSymbolView

@synthesize _1Layer;
@synthesize _2Layer;
@synthesize _3Layer;
@synthesize _4Layer;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupSubLayers];
    }
    return self;
}


-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

//    CGFloat width = frame.size.width/2;
//    CGFloat height = frame.size.height/2;

//    _1Layer.frame = CGRectMake(0, 0, width+1, height);
//    _2Layer.frame = CGRectMake(width, 0, width, height);
//    _3Layer.frame = CGRectMake(0, height-1, width+1, height);
//    _4Layer.frame = CGRectMake(width, height-1, width, height);

//    _1Layer.frame = CGRectMake(0, 0, width, height);
//    _2Layer.frame = CGRectMake(width, 0, width, height);
//    _3Layer.frame = CGRectMake(0, height, width, height);
//    _4Layer.frame = CGRectMake(width, height, width, height);
}


-(void) setupSubLayers
{
    CATransformLayer* containerLayer = self.containerLayer;
    // upleft
    _1Layer = [SeparateSymbolView createSymbolLayer:containerLayer];
    _1Layer.backgroundColor = [[UIColor flatBlueColor] CGColor];
    
    // downleft
    _4Layer = [SeparateSymbolView createSymbolLayer:containerLayer];
    _4Layer.backgroundColor = [[UIColor flatBlueColor] CGColor];
    
    // upright
    _2Layer = [SeparateSymbolView createSymbolLayer:containerLayer];
    _2Layer.backgroundColor = [[UIColor flatBlueColor] CGColor];
    
    // downright
    _3Layer = [SeparateSymbolView createSymbolLayer:containerLayer];
    _3Layer.backgroundColor = [[UIColor flatBlueColor] CGColor];
}

+(SymbolLayer*) createSymbolLayer: (CATransformLayer*)containerLayer
{
    SymbolLayer* symbolLayer = [SymbolLayer layer];
    [containerLayer addSublayer: symbolLayer];
    return symbolLayer;
}


- (void)setTransformProgress:(float)startTransformValue
                            :(float)endTransformValue
                            :(float)duration
                            :(int)aX
                            :(int)aY
                            :(int)aZ
                            :(BOOL)setDelegate
                            :(BOOL)removedOnCompletion
                            :(NSString *)fillMode
                            :(CALayer *)targetLayer
{
    //NSLog(@"transform value %f, %f", startTransformValue, endTransformValue);
    
    CATransform3D aTransform = CATransform3DIdentity;
    aTransform.m34 = -1.0 / 100;
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.duration = duration;
    anim.fromValue= [NSValue valueWithCATransform3D:CATransform3DRotate(aTransform, startTransformValue, aX, aY, aZ)];
    anim.toValue=[NSValue valueWithCATransform3D:CATransform3DRotate(aTransform, endTransformValue, aX, aY, aZ)];
    if (setDelegate) {
        anim.delegate = self;
    }
    anim.removedOnCompletion = removedOnCompletion;
    [anim setFillMode:fillMode];
    
    [targetLayer addAnimation:anim forKey:@"transformAnimation"];
    
    
    
    //        [LayerHelper setAnchorPoint:CGPointMake(0.5, 1) forLayer:symbol._1Layer];
    //        [LayerHelper setAnchorPoint:CGPointMake(0.5, 1) forLayer:symbol._2Layer];
    //        [LayerHelper setAnchorPoint:CGPointMake(0.5, 0) forLayer:symbol._3Layer];
    //        [LayerHelper setAnchorPoint:CGPointMake(0.5, 0) forLayer:symbol._4Layer];
    //        [symbol setTransformProgress: 0 :-3.14f :1.6 :1 :0 :0 :NO :YES :kCAFillModeForwards :symbol._1Layer];
    //        [symbol setTransformProgress: 0 :-3.14f :1.6 :1 :0 :0 :NO :YES :kCAFillModeForwards :symbol._2Layer];
    //        [symbol setTransformProgress: 0 :3.14f :1.6 :1 :0 :0 :NO :YES :kCAFillModeForwards :symbol._3Layer];
    //        [symbol setTransformProgress: 0 :3.14f :1.6 :1 :0 :0 :NO :YES :kCAFillModeForwards :symbol._4Layer];
}

@end
