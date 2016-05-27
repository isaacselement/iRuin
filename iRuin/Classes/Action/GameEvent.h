#import <Foundation/Foundation.h>

@interface GameEvent : NSObject

-(void) launchGame;

-(void) gameStart;

-(void) gameReStart;

-(void) gameBack;

-(void) gamePause;

-(void) gameResume;

-(void) gameOver;

-(void) gameRefresh;

@end
