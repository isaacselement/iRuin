#import <Foundation/Foundation.h>

@class BaseEvent;
@class SymbolView;
@class QueueTimeCalculator;

@interface BaseEffect : NSObject

@property (assign) BaseEvent* event;

#pragma mark - Subclass Override Methods
- (void)effectInitialize;
- (void)effectTouchesBegan:(SymbolView*)symbol location:(CGPoint)location;
- (void)effectTouchesMoved:(SymbolView*)symbol location:(CGPoint)location;
- (void)effectTouchesEnded:(SymbolView*)symbol location:(CGPoint)location;
- (void)effectTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location;



#pragma mark - Public Methods
-(void) effectStartRollIn ;
-(void) effectStartVanish: (NSMutableArray*)symbols;


// Adjust is the phase of adjusting the empty
// FillIn is the pahse of filling the empty, waiting until Adjust done , do FillIn
// Squeeze is the connected phase of Adjust and Fill , just not waiting until Adjust done and start the FillIn simultaneously. You should choose one of Adjust or Squeeze when vanish Done in 'stateStartNextPhase' .
-(void) effectStartAdjusts: (NSArray*)nullRowColumns;
-(void) effectStartFillIn;
-(void) effectStartSqueeze: (NSArray*)nullRowColumns;

@end
