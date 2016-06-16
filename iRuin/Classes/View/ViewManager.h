#import <Foundation/Foundation.h>

#define VIEW [ViewManager getInstance]





#define effect_Font             @"FONT"

#define effect_AUDIO            @"audio"
#define effect_ANIMATION        @"images.play"

#define effect_ValuesSet        @"values.set"
#define effect_ValuesAnimation  @"values.animation"

#define effect_Movement         @"positions.move"
#define effect_Explode          @"tiles.explode"

#define effect_Invocation       @"Invocation"






@class GameView;
@class ChaptersView;
@class GameController;
@class QueueTimeCalculator;
@class ActionExecutorManager;






@interface ViewManager : NSObject


@property (assign) UIWindow* window;

@property (strong) GameController* controller;


@property (strong, readonly) QueueTimeCalculator* actionDurations;

@property (strong, readonly) ActionExecutorManager* actionExecutorManager;


@property (assign) CGPoint blackPoint;


+(ViewManager*) getInstance ;

-(GameView*) gameView;

-(ChaptersView*) chaptersView;

-(void) initializeWithData ;



@end
