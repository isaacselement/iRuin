#import <Foundation/Foundation.h>

#define ACTION [ActionManager getInstance]


#define kEVENT     @"Event"
#define kSTATE     @"State"
#define kEFFECT    @"Effect"

@class GameEvent;
@class GameState;
@class GameEffect;

@class BaseEvent;
@class BaseState;
@class BaseEffect;

@interface ActionManager : NSObject

@property (strong) GameEvent* gameEvent;
@property (strong) GameState* gameState;
@property (strong) GameEffect* gameEffect;

// modes
@property (strong, readonly) NSMutableDictionary* modesRepository;

@property (assign) BaseEvent* modeEvent;
@property (assign) BaseState* modeState;
@property (assign) BaseEffect* modeEffect;


+(ActionManager*) getInstance ;

-(void) launchAppProcedures ;



#pragma mark -

-(void) renderFramesWithCurrentOrientation;

-(void) switchToMode: (NSString*)mode chapter:(int)chapter;


@end
