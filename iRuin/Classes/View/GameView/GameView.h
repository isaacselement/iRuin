#import "GameBaseView.h"

@class HeaderView;
@class ContainerView;

@interface GameView : GameBaseView

@property (strong, readonly) HeaderView* headerView;
@property (strong, readonly) ContainerView* containerView;


-(NSMutableArray*) symbolsInContainer;

@end
