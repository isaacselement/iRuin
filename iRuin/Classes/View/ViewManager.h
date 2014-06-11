#import <Foundation/Foundation.h>

#define VIEW [ViewManager getInstance]

#define effect_Font     @"FONT"

#define effect_ValueSet         @"value.set"
#define effect_ValuesAnimation  @"values.animation"

#define effect_Movement         @"positions.move"
#define effect_Explode          @"tiles.explode"

#define effect_AUDIO        @"audio.play"
#define effect_ANIMATION    @"images.play"


@class GameView;
@class GameController;

@class FrameManager;

@class QueueTimeCalculator;
@class ActionExecutorManager;

@interface ViewManager : NSObject

@property (strong) UIWindow* window;
@property (strong) GameView* gameView;
@property (strong) FrameManager* frame;
@property (strong) GameController* controller;

@property (strong, readonly) QueueTimeCalculator* actionDurations;
@property (strong, readonly) ActionExecutorManager* actionExecutorManager;

+(ViewManager*) getInstance ;


-(void) initializeWithData ;

@end
