#import "BaseState.h"
#import "AppInterface.h"

@implementation BaseState

@synthesize effect;

#pragma mark - Subclass Override Methods
-(void) stateInitialize
{
}
-(void) stateTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    [effect effectTouchesBegan: symbol location:location];
}
-(void) stateTouchesMoved:(SymbolView*)symbol location:(CGPoint)location
{
    [effect effectTouchesMoved: symbol location:location];
}
-(void) stateTouchesEnded:(SymbolView*)symbol location:(CGPoint)location
{
    [effect effectTouchesEnded: symbol location:location];
}
-(void) stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    [effect effectTouchesCancelled: symbol location:location];
}



#pragma mark - Public Methods



@end
