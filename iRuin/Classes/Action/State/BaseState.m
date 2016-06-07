#import "BaseState.h"
#import "AppInterface.h"

@implementation BaseState

@synthesize effect;

#pragma mark - Subclass Override Methods
-(void) stateInitialize
{
}
-(void) stateUnInitialize
{
}
-(void) stateTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    [effect effectTouchesBegan: symbol location:location];
}
-(void) stateTouchesMoved:(SymbolView*)symbol location:(CGPoint)location
{
//    [effect effectTouchesMoved: symbol location:location];    // give to everyone state to handle it.
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

-(void) stateSymbolsWillRollIn
{
    
}

-(void) stateSymbolsDidRollIn
{
    
}

-(void) stateSymbolsWillRollOut
{
    
}

-(void) stateSymbolsDidRollOut
{
    
}

-(void) stateSymbolsWillVanish: (NSArray*)symbols
{
    self.isSymbolsOnVAFSing = YES;
    
    [[EffectHelper getInstance] startScoresEffect: symbols];
}

-(void) stateSymbolsDidVanish: (NSArray*)symbols
{
    
}

-(void) stateSymbolsWillAdjusts
{
    
}

-(void) stateSymbolsDidAdjusts
{
    
}

-(void) stateSymbolsWillFillIn
{
    
}

-(void) stateSymbolsDidFillIn
{
    self.isSymbolsOnVAFSing = NO;
}

-(void) stateSymbolsWillSqueeze
{
    
}

-(void) stateSymbolsDidSqueeze
{
    self.isSymbolsOnVAFSing = NO;
}

@end
