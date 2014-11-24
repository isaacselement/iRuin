#import <Foundation/Foundation.h>


@interface GameState : NSObject


@property (assign) BOOL isGameStarted;


@property (assign) int currentChapter;




@property (assign) BOOL isChainVanishing;

@property (assign) BOOL isSymbolsOnVAFSing;





@property (assign) int vanishAmount;

@property (assign) int vanishScores;


@property (assign) int vanishTotalAmount;

@property (assign) int vanishTotalScores;


@end
