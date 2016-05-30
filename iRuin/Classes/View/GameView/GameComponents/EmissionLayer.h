#import <QuartzCore/QuartzCore.h>

@class CAEmitterCell;

@interface EmissionLayer : CAEmitterLayer

@property (assign, nonatomic) CAEmitterCell* cell;

@end
