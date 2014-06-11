#import <Foundation/Foundation.h>

#define ACTION [ActionManager getInstance]


#define kEVENT     @"Event"
#define kSTATE     @"State"
#define kEFFECT    @"Effect"

#define MODE_MOVE   @"Move"
#define MODE_TOUCH  @"Touch"
#define MODE_SWIPE  @"Swipe"
#define MODE_PULL   @"Pull"
#define MODE_DOTS   @"Dots"
#define MODE_BLANK  @"Blank"


@class GameEvent;
@class GameState;

@class BaseEvent;
@class BaseState;
@class BaseEffect;

@interface ActionManager : NSObject

@property (strong) GameEvent* gameEvent;
@property (strong) GameState* gameState;

// modes
@property (strong, readonly) NSArray* gameModes;
@property (strong, readonly) NSMutableDictionary* modesRepository;

@property (assign) BaseEvent* currentEvent;
@property (assign) BaseState* currentState;
@property (assign) BaseEffect* currentEffect;


+(ActionManager*) getInstance ;

-(void) launchAppProcedures ;



#pragma mark -
-(void) renderFramesWithCurrentOrientation;


@end
