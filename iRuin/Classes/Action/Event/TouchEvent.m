#import "TouchEvent.h"
#import "AppInterface.h"

@implementation TouchEvent

-(void)eventInitialize
{
    [super eventInitialize];
    
    self.isDisableChainable = YES;
}

@end
