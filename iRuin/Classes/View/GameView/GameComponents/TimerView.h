#import "GradientLabel.h"

@interface TimerView : GradientLabel


@property (assign, nonatomic) double totalTime;

@property (assign, readonly) double currentTime;

@property (strong) NSString* timerFormat;


@property (copy) void(^timeIsOverAction)(TimerView* timerView);



-(void) resumeTimer ;

-(void) pauseTimer ;



@end
