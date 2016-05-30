#import "EmissionLayer.h"
#import "AppInterface.h"

@implementation EmissionLayer

-(CAEmitterCell *) cell
{
    return [self.emitterCells firstObject];
}

-(void) setCell:(CAEmitterCell *)cell
{
    self.emitterCells = @[cell];
}

@end
