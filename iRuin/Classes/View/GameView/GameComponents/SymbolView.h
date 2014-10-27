#import <UIKit/UIKit.h>

@interface SymbolView : UIView

@property(assign) int identification;
@property(strong, nonatomic) NSString* name;

@property(assign, nonatomic) int row;
@property(assign, nonatomic) int column;

// sublayers
@property(strong) CATransformLayer* containerLayer;




#pragma mark - Public Methods
-(void) vanish;
-(void) restore;
-(void) addEllipseInRectWithAnimation;

-(void) setValidArea: (CGRect)rect;
-(BOOL) isInValidArea: (CGPoint)location;


@end





