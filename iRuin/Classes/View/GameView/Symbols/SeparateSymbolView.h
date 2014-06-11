#import "SymbolView.h"

@class SymbolLayer;



@interface SeparateSymbolView : SymbolView

@property(strong) SymbolLayer* _1Layer;
@property(strong) SymbolLayer* _2Layer;
@property(strong) SymbolLayer* _3Layer;
@property(strong) SymbolLayer* _4Layer;

- (void)setTransformProgress:(float)startTransformValue
                            :(float)endTransformValue
                            :(float)duration
                            :(int)aX
                            :(int)aY
                            :(int)aZ
                            :(BOOL)setDelegate
                            :(BOOL)removedOnCompletion
                            :(NSString *)fillMode
                            :(CALayer *)targetLayer;

@end
