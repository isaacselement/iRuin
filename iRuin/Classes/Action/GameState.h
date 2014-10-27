#import <Foundation/Foundation.h>


@interface GameState : NSObject


@property (assign) BOOL isGameStarted;

@property (assign) BOOL isViewsDidRollIn;


-(NSString*) oneRandomSymbolName;

@end
