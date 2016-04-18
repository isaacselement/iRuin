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
    NSDictionary* configs = DATA.config[@"Controller_Schedule_Task"];
    for (NSString* key in configs) {
        NSMutableDictionary* config = configs[key];
        int interval = [config[@"~interval"] intValue];
        if (interval <= 0) continue;
        if (scheduleTaskTimes % interval == 0) {
            NSDictionary* scheduleTaskConfig = [ConfigHelper getLoopConfig:config index:scheduleViewValueIndex] ;
            [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:scheduleTaskConfig];
            scheduleViewValueIndex++;
        }
    }
    
    // count
    scheduleTaskTimes++;
}

@end
