#import "EffectHelper.h"
#import "AppInterface.h"

@implementation EffectHelper
{
    NSMutableDictionary* scheduleTaskConfig;
    
    NSArray* imagesValues ;
    
    int imageIndex;
}

static EffectHelper* oneInstance = nil;

+(EffectHelper*) getInstance
{
    if (!oneInstance) {
        oneInstance = [[EffectHelper alloc] init];
    }
    return oneInstance;
}


-(void) updateScheduleTaskConfigAndRegistryToTask
{
    // handler the config
    scheduleTaskConfig = [DictionaryHelper deepCopy:DATA.config[@"GAME_LAUNCH_ScheduleTask"]];
    
    int interval = [scheduleTaskConfig[@"ScheduleTask_Interval"] intValue];
    [scheduleTaskConfig removeObjectForKey:@"ScheduleTask_Interval"];
    
    imagesValues = [scheduleTaskConfig objectForKey:@"view.backgroundView.values"];
    
    [scheduleTaskConfig removeObjectForKey:@"view.backgroundView.values"];
    
    // schedule task
    if (interval == 0) interval = 60;
    [[ScheduledTask sharedInstance] unRegisterSchedule: self];
    [[ScheduledTask sharedInstance] registerSchedule: self timeElapsed:interval repeats:0];
}



#pragma mark - Scheduled Action

-(void) scheduledTask
{
    imageIndex = imageIndex % imagesValues.count;
    NSString* currentImage = [imagesValues objectAtIndex: imageIndex];
    imageIndex++;
    
    NSMutableDictionary* config = scheduleTaskConfig[@"view"][@"backgroundView"][@"Executors"][@"1"];
    [config setObject: currentImage forKey:@"values"];
    
    [ACTION.gameEffect designateValuesActionsTo:VIEW.controller config:scheduleTaskConfig];
}




@end
