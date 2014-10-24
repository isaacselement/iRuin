#import <UIKit/UIKit.h>

@class Symbol;


@interface SymbolView : UIView

@property(assign, nonatomic) int row;
@property(assign, nonatomic) int column;
@property(strong, nonatomic) Symbol* prototype;

// sublayers
@property(strong) CATransformLayer* containerLayer;




#pragma mark - Public Methods
-(void) vanish;
-(void) restore;
-(void) addEllipseInRectWithAnimation;

-(void) setValidArea: (CGRect)rect;
-(BOOL) isInValidArea: (CGPoint)location;


@end





