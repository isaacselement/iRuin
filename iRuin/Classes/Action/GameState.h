#import <Foundation/Foundation.h>


@interface GameState : NSObject



@property (assign) BOOL isMuteMusic;




@property (assign) BOOL isGameStarted;



@property (assign) int currentChapter;

@property (strong) NSString* currentMode;




@property (assign) BOOL isChainVanishing;

@property (assign) BOOL isSymbolsOnVAFSing;





@property (assign) int vanishAmount;

@property (assign) int vanishScores;


@property (assign) int vanishTotalAmount;

@property (assign) int vanishTotalScores;




@end
