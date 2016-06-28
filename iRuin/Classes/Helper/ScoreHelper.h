#import <Foundation/Foundation.h>

@interface ScoreHelper : NSObject

@property (assign) int clearedContinuous;
@property (assign) int clearedVanishedCount;
@property (assign) int clearedVanishedViewCount;


+(ScoreHelper*) getInstance;

-(void) setupClearedSeasonStatus;

-(void) checkIsClearedSeasonOnSymbolVanish;
-(void) checkIsClearedSeasonOnTimesOut;


@end
