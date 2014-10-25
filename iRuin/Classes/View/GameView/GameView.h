#import "BaseGameView.h"

@class HeaderView;
@class ContainerView;

@interface GameView : BaseGameView

@property (strong, readonly) HeaderView* headerView;
@property (strong, readonly) ContainerView* containerView;


-(NSMutableArray*) symbolsInContainer;

@end
