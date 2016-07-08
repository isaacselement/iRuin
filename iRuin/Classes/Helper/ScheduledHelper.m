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



#pragma mark - ScheduledTaskProtocol

-(void) scheduledTask
{    
    NSDictionary* configs = DATA.config[@"Controller_Schedule_Task"];
    for (NSString* key in configs) {
        NSMutableDictionary* config = configs[key];
        int interval = [config[kReservedInterval] intValue];
        if (scheduleTaskTimes == 0 || interval <= 0) continue;
        if (scheduleTaskTimes % interval == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary* scheduleTaskConfig = [ConfigHelper getLoopConfig:config index:scheduleViewValueIndex] ;
                [ACTION.gameEffect designateToControllerWithConfig:scheduleTaskConfig];
                scheduleViewValueIndex++;                
            });
        }
    }
    
    // check config
    int configInterval = [DATA.config[@"__interval__"] intValue];
    if (configInterval != 0 && scheduleTaskTimes % configInterval == 0) {
        [ConfigHelper requestDowloadResources];
    }
    
    // increment times count
    scheduleTaskTimes++;
}

@end
