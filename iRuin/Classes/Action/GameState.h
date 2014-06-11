#import <Foundation/Foundation.h>

@class Symbol;

@interface GameState : NSObject


@property (assign) BOOL isGameStarted;

@property (assign) BOOL isViewsDidRollIn;

@property (strong, readonly) NSMutableArray* prototypes;


-(void) initializePrototypes;
-(Symbol*) oneRandomPrototype;

@end
