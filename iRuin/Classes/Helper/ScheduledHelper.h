#import <Foundation/Foundation.h>

@interface ScheduledHelper : NSObject


+(ScheduledHelper*) sharedInstance;



#pragma mark - Schedule Action

-(void) unRegisterScheduleTaskAccordingConfig;

-(void) registerScheduleTaskAccordingConfig;



@end
