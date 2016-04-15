#import "ScheduledHelper.h"
#import "AppInterface.h"

@implementation ScheduledHelper
{
    // schedule action
    int scheduleTaskTimes;
    
    // for view
    int scheduleViewValueIndex;
}



static ScheduledHelper* scheduledHelper = nil;

+(ScheduledHelper*) sharedInstance
{
    if (!scheduledHelper) {
        scheduledHelper = [[ScheduledHelper alloc] init];
    }
    return scheduledHelper;
}



#pragma mark - Schedule Action
-(void) registerScheduleTaskAccordingConfig
{
    [self unRegisterScheduleTaskAccordingConfig];
    [[ScheduledTask sharedInstance] registerSchedule: self timeElapsed:1 repeats:0];
}

-(void) unRegisterScheduleTaskAccordingConfig
{
    [[ScheduledTask sharedInstance] unRegisterSchedule: self];
}


-(void) scheduledTask
{
    // view
    int viewInterval = [[ConfigHelper getUtilitiesConfig:@"ScheduleTask.view.interval"] intValue];
    if (viewInterval == 0) viewInterval = 60;
    
    if (scheduleTaskTimes % viewInterval == 0) {
        [self refreshViewBackgroundJob];
    }
    
    // count
    scheduleTaskTimes++;
}


#pragma mark - Scheduled Jobs

-(void) refreshViewBackgroundJob
{
    NSDictionary* scheduleTaskConfig = [ConfigHelper getLoopConfig:DATA.config[@"GAME_LAUNCH_ScheduleTask"] index:scheduleViewValueIndex] ;
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:scheduleTaskConfig];
    scheduleViewValueIndex++;
}



@end
