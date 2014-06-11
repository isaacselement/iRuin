#import <UIKit/UIKit.h>

@class HeaderView;
@class ContainerView;

@interface GameView : UIView

@property (strong, readonly) HeaderView* headerView;
@property (strong, readonly) ContainerView* containerView;


-(NSMutableArray*) symbolsInContainer;

@end
