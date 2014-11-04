#import <Foundation/Foundation.h>

@class BaseState;
@class SymbolView;

@interface BaseEvent : NSObject

@property (assign) BaseState* state;


#pragma mark - Subclass Override Methods
- (void)eventInitialize;
- (void)eventTouchesBegan:(SymbolView*)symbol location:(CGPoint)location;
- (void)eventTouchesMoved:(SymbolView*)symbol location:(CGPoint)location;
- (void)eventTouchesEnded:(SymbolView*)symbol location:(CGPoint)location;
- (void)eventTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location;


#pragma mark - Event Methods
-(void) eventSymbolsWillRollIn;
-(void) eventSymbolsDidRollIn;

-(void) eventSymbolsWillRollOut;
-(void) eventSymbolsDidRollOut;

-(void) eventSymbolsWillVanish: (NSArray*)symbols;
-(void) eventSymbolsDidVanish: (NSArray*)symbols;

-(void) eventSymbolsWillAdjusts;
-(void) eventSymbolsDidAdjusts;

-(void) eventSymbolsWillFillIn;
-(void) eventSymbolsDidFillIn;

-(void) eventSymbolsWillSqueeze;
-(void) eventSymbolsDidSqueeze;

@end
