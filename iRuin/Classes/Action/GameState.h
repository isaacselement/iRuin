#import <Foundation/Foundation.h>


@interface GameState : NSObject


@property (assign) int orientation;

@property (assign) BOOL isGameStarted;

@property (assign) int currentChapter;

@property (assign) int vanishAmount;


@end
