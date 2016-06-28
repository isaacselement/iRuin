#import <Foundation/Foundation.h>


@interface GameState : NSObject


@property (assign) BOOL isGameStarted;

@property (assign) int currentChapter;
@property (strong) NSString* currentMode;


@property (assign) int vanishCount;
@property (assign, nonatomic) int vanishViewsAmount;


@end
