#import <UIKit/UIKit.h>

@interface SymbolView : UIView

@property(assign, nonatomic) float score;
// identification cannot be 0
@property(assign, nonatomic) int identification;

@property(assign, nonatomic) int row;
@property(assign, nonatomic) int column;

// sublayers
//@property(strong) CATransformLayer* containerLayer;




#pragma mark - Public Methods
-(void) restore;

-(void) setValidArea: (CGRect)rect;
-(BOOL) isInValidArea: (CGPoint)location;





#pragma mark - Class Methods


+(int) getOneRandomSymbolIdentification;


@end
