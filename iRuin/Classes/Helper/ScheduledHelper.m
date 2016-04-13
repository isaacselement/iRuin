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
    NSArray* values = [ConfigHelper getUtilitiesConfig:@"ScheduleTask.view.values"];
    NSMutableDictionary* scheduleTaskConfig = DATA.config[@"GAME_LAUNCH_ScheduleTask"];
    NSMutableDictionary* valuesConfig = scheduleTaskConfig[@"view"][@"backgroundView"][@"Executors"][@"1"];
    
    scheduleViewValueIndex = scheduleViewValueIndex % [values count];
    [valuesConfig setObject: [values objectAtIndex: scheduleViewValueIndex] forKey:@"values"];
    scheduleViewValueIndex++;
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:scheduleTaskConfig];
}



@end
