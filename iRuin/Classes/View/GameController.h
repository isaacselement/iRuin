#import "BaseController.h"

@class GameView;
@class ChaptersView;
@class EmissionLayer;

@interface GameController : BaseController

@property (strong) GameView* gameView;
@property (strong) ChaptersView* chaptersView;
//@property (strong) EmissionLayer* emissionLayer;

@end
