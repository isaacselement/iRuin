#import <UIKit/UIKit.h>

@interface ContainerView : UIView


//@property (assign) CGPathRef areaPathInContainer;


#pragma mark - Public Methods

- (void)touchesBegan:(CGPoint)location event:(UIEvent *)event;
- (void)touchesMoved:(CGPoint)location event:(UIEvent *)event;
- (void)touchesEnded:(CGPoint)location event:(UIEvent *)event;
- (void)touchesCancelled:(CGPoint)location event:(UIEvent *)event;



@end

