#import "BaseController.h"


@class GameView;
@class ChaptersView;


@interface GameController : BaseController


@property (strong) GameView* gameView;
@property (strong) ChaptersView* chaptersView;


-(void) switchToView: (UIView*)view ;


@end
