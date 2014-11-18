#import <Foundation/Foundation.h>


@interface GameState : NSObject


@property (assign) int orientation;

@property (assign) BOOL isGameStarted;


@property (assign) BOOL isSymbolsOnVAFSing;

@property (assign) BOOL isChainVanishing;



@property (assign) int currentChapter;

@property (assign) int vanishAmount;


@end
