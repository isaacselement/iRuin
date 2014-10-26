#import "RotatableViewController.h"


@class GameView;
@class ChaptersView;


@interface GameController : RotatableViewController


@property (strong) GameView* gameView;
@property (strong) ChaptersView* chaptersView;


-(void) switchToView: (UIView*)view ;


@end
