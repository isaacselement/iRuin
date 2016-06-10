#import <Foundation/Foundation.h>

@class BaseState;
@class SymbolView;

@interface BaseEvent : NSObject

@property (assign) BaseState* state;


#pragma mark - Subclass Override Methods
- (void)eventInitialize;
- (void)eventUnInitialize;
- (void)eventTouchesBegan:(SymbolView*)symbol location:(CGPoint)location;
- (void)eventTouchesMoved:(SymbolView*)symbol location:(CGPoint)location;
- (void)eventTouchesEnded:(SymbolView*)symbol location:(CGPoint)location;
- (void)eventTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location;


#pragma mark - Event Methods
-(void) eventSymbolsWillRollIn;
-(void) eventSymbolsDidRollIn;

-(void) eventSymbolsWillRollOut;
-(void) eventSymbolsDidRollOut;

-(void) eventSymbolsDidVanish: (NSArray*)symbols;

-(void) eventSymbolsDidAdjusts;

-(void) eventSymbolsDidFillIn;

-(void) eventSymbolsDidSqueeze;

@end
