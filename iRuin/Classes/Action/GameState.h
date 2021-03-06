#import <Foundation/Foundation.h>


@interface GameState : NSObject


@property (assign) int currentChapter;
@property (strong) NSString* currentMode;

@property (assign) int vanishCount;
@property (assign) int continuousCount;
@property (assign, nonatomic) int vanishViewsAmount;


- (void)resetStatus;

- (void)startBonusEffect: (int)count;


@end
