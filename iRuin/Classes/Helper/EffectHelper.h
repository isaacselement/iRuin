#import <Foundation/Foundation.h>

@interface EffectHelper : NSObject


+(EffectHelper*) getInstance;


-(void) updateScheduleTaskConfigAndRegistryToTask;




#pragma mark - Public Methods

-(void) muteBackGroundMusic: (BOOL)isMute;




@end
