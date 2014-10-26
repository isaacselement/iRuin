#import <Foundation/Foundation.h>

#define VIEW [ViewManager getInstance]


@class GameView;
@class ChaptersView;
@class GameController;

@class FrameManager;

@class QueueTimeCalculator;
@class ActionExecutorManager;

@interface ViewManager : NSObject

@property (assign) UIWindow* window;

@property (strong) FrameManager* frame;
@property (strong) GameController* controller;


@property (strong, readonly) QueueTimeCalculator* actionDurations;
@property (strong, readonly) ActionExecutorManager* actionExecutorManager;

+(ViewManager*) getInstance ;

-(GameView*) gameView;

-(ChaptersView*) chaptersView;

-(void) initializeWithData ;



@end
