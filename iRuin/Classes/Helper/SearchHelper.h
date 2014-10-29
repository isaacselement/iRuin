#import <Foundation/Foundation.h>


typedef enum APPDirection : NSUInteger APPDirection;
enum APPDirection : NSUInteger {
    DirectionNONE       = 0,
    DirectionUPLEFT     = 1 << 0,
    DirectionUP         = 1 << 1,
    DirectionUPRIGHT    = 1 << 2,
    DirectionRIGHT      = 1 << 3,
    DirectionDOWNRIGHT  = 1 << 4,
    DirectionDOWN       = 1 << 5,
    DirectionDOWNLEFT   = 1 << 6,
    DirectionLEFT       = 1 << 7
};


@class SymbolView;

@interface SearchHelper : NSObject




#pragma mark -

#pragma mark - SEARCH
+(NSMutableArray*) searchExplodeMatchedSymbols: (SymbolView*)symbol;
+(NSMutableArray*) searchTouchMatchedSymbols: (SymbolView*)symbol;
+(NSMutableArray*) searchMoveMatchedSymbols: (NSArray*)routeSymbols;
+(NSMutableArray*) searchDotsMatchedSymbols: (SymbolView*)firstSymbol secondSymbol:(SymbolView*)secondSymbol;
+(NSMutableArray*) searchSwipeMatchedSymbols: (SymbolView*)firstSymbol secondSymbol:(SymbolView*)secondSymbol;



+(NSMutableArray*) searchMatchedInSameLine:(int)matchCount;



#pragma mark -

#pragma mark - GET

+(NSMutableArray*) getHorizontally: (SymbolView*)symbol;

+(NSMutableArray*) getVertically: (SymbolView*)symbol;


#pragma mark -

+(SymbolView*) getAdjacentSymbolByDirection: (SymbolView*)symbol start:(CGPoint)start end:(CGPoint)end;
+(SymbolView*) getAdjacentSymbolByDirection: (SymbolView*)symbol direction:(APPDirection)direction;

@end
