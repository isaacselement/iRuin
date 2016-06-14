#import "ChainableEffect.h"
#import "AppInterface.h"

@implementation ChainableEffect


#pragma mark - Override Methods

-(void) effectStartAdjustFillSqueeze:(NSArray*)vanishingViews vanishDuration:(double)vanishDuration
{
    if (self.isSqueezeEnable){
        // .Squeeze
        [self effectStartSqueeze:vanishingViews vanishDuration:vanishDuration];
    } else {
        // .Adjust
        double adjustDuration = [self effectStartAdjust:vanishingViews vanishDuration:vanishDuration];
        
        // adjustDuration == 0 , that means that no adjust phase
        if (((ChainableState*)ACTION.modeState).isAdjustChaining && adjustDuration != 0) {
            return;
        }
        
        // .Fill
        [self effectStartFill:vanishingViews fillDelayTime:adjustDuration];
    }
}

@end
