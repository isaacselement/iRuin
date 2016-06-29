#import <Foundation/Foundation.h>

@interface ScoreHelper : NSObject

@property (assign, readonly) int clearedContinuous;
@property (assign, readonly) int clearedVanishedCount;
@property (assign, readonly) int clearedVanishedViewCount;


+(ScoreHelper*) getInstance;

-(void) setupClearedSeasonStatus;

-(void) checkIsClearedSeasonOnSymbolVanish;
-(void) checkIsClearedSeasonOnTimesOut;


@end
