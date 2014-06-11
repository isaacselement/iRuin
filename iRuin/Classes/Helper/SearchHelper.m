#import "SearchHelper.h"
#import "AppInterface.h"

/**
 *  search prefix like (search*) methods : seach the same id
 *  get prefix like (get*) methods : include the not same id
 *
 *
 *  Direction can be APPDection or an 'startPoint' Point to 'endPoint'
 *
 *
 */
@implementation SearchHelper


#pragma mark - 

#pragma mark - SEARCH


+(NSMutableArray*) searchTouchMatchedSymbols: (SymbolView*)symbol
{
    NSMutableSet* repository = [NSMutableSet setWithCapacity: 1];
    [self searchConnectedSymbols: symbol repository:repository];
    return [NSMutableArray arrayWithArray: [repository allObjects]];
}



+(NSMutableArray*) searchMoveMatchedSymbols: (NSArray*)routeSymbols
{
    SymbolView* baseSymbolView = [routeSymbols objectAtIndex: 0];
    NSMutableArray* array = [NSMutableArray arrayWithCapacity: routeSymbols.count];
    
    for (int i = 0 ; i < routeSymbols.count ; i++) {
        SymbolView* checkedSymbolView = [routeSymbols objectAtIndex: i];
        if (checkedSymbolView.prototype.identification != baseSymbolView.prototype.identification){
            break;
        }
        [array addObject:checkedSymbolView];
    }
    return array;
}


+(NSMutableArray*) searchDotsMatchedSymbols: (SymbolView*)firstSymbol secondSymbol:(SymbolView*)secondSymbol
{
    return [self searchMatchedAround: firstSymbol and:secondSymbol];
}

+(NSMutableArray*) searchSwipeMatchedSymbols: (SymbolView*)firstSymbol secondSymbol:(SymbolView*)secondSymbol
{
    return [self searchMatchedAround: firstSymbol and:secondSymbol];
}


// For two symbol exchange their positions
+(NSMutableArray*) searchMatchedAround: (SymbolView*)firstSymbol and:(SymbolView*)secondSymbol
{
    NSMutableArray* array = [NSMutableArray array];
    NSMutableArray *a = nil, *b = nil, *c = nil, *d = nil;
    
    a = [self searchHorizontally: firstSymbol];
    if (a.count >= MATCH_COUNT) {
        [array addObjectsFromArray: a];
    }
    c = [self searchVertically: firstSymbol];
    if (c.count >= MATCH_COUNT) {
        [array addObjectsFromArray: c];
    }
    
    
    if (![a containsObject: secondSymbol]){
        b = [self searchHorizontally: secondSymbol];
        if (b.count >= MATCH_COUNT) {
            [array addObjectsFromArray: b];
        }
    }
    if ( ![c containsObject: secondSymbol]){
        d = [self searchVertically: secondSymbol];
        if (d.count >= MATCH_COUNT) {
            [array addObjectsFromArray: d];
        }
    }
    
    return [ArrayHelper eliminateDuplicates: array];
}


// For Chainable Modes
+(NSMutableArray*) searchMatchedInAllSymbols
{
    NSArray* symbolsAtContainer = VIEW.gameView.symbolsInContainer;
    NSMutableSet* resultsSet = [NSMutableSet set];
    
    for (int i = 0; i < symbolsAtContainer.count; i++) {
        NSArray* innerArray = [symbolsAtContainer objectAtIndex: i];
        for (int j = 0; j < innerArray.count; j++) {
            SymbolView* symbol = [innerArray objectAtIndex: j];

            NSMutableArray* arrayHor = [self searchHorizontally: symbol];
            if (arrayHor.count >= MATCH_COUNT) {
                [resultsSet addObjectsFromArray: arrayHor];
            }
            NSMutableArray* arrayVer = [self searchVertically: symbol];
            if (arrayVer.count >= MATCH_COUNT) {
                [resultsSet addObjectsFromArray: arrayVer];
            }
        }
    }
    
    NSArray* matchedSymbols = [resultsSet allObjects];
    return matchedSymbols.count >= MATCH_COUNT ? [NSMutableArray arrayWithArray: matchedSymbols] : nil;
}



#pragma mark - Contains The Symbol You Passed

// connected means just left, up, right , down , these four directions  .
+(void) searchConnectedSymbols: (SymbolView*)symbol repository:(NSMutableSet*)repository
{
    if (!symbol) return ;
    
    [repository addObject: symbol];
    NSMutableArray* results = [self searchBothHorizontallyAndVertically: symbol];
    for (SymbolView* symbolObj in results) {
        if (! [repository containsObject: symbolObj]) {
            [self searchConnectedSymbols: symbolObj repository:repository];
        }
    }
}

+(NSMutableArray*) searchBothHorizontallyAndVertically: (SymbolView*)symbol
{
    if (!symbol) return nil;
    
    NSMutableArray* results = [NSMutableArray array];
    NSMutableArray* verticals = [self searchVertically: symbol];
    [results addObjectsFromArray:verticals];
    
    NSMutableArray* horizontals = [self searchHorizontally: symbol];
    [results addObjectsFromArray:horizontals];
    
    [results removeObject: symbol];         // remove all object == symbol . cause vertical has one , and horizontals has one .
    [results addObject: symbol];
    
    return results;
}

+(NSMutableArray*) searchHorizontally: (SymbolView*)symbol
{
    if (!symbol) return nil;
    
    NSMutableArray* array = [self searchSameLinesSymbols: symbol directions: DirectionRIGHT | DirectionLEFT];
    NSMutableArray* results = [ArrayHelper translateToOneDimension: array];
    [results addObject: symbol];
    return results;
}

+(NSMutableArray*) searchVertically: (SymbolView*)symbol
{
    if (!symbol) return nil;
    
    NSMutableArray* array = [self searchSameLinesSymbols: symbol directions: DirectionUP | DirectionDOWN];
    NSMutableArray* results = [ArrayHelper translateToOneDimension: array];
    [results addObject: symbol];
    return results;
}







#pragma mark - Not Contains The Symbol You Passed

// search same id symbol in same many line for directions, return two dimension array, the result not include the symbol you passed
+(NSMutableArray*) searchSameLinesSymbols: (SymbolView*)symbol directions:(APPDirection)directions
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity: 1];
    
    [self iterateDirections: directions handler:^BOOL(APPDirection direction) {
        NSMutableArray* results = [self searchSameLineSymbols: symbol direction:direction];
        [array addObject: results];
        return NO;
    }];
    
    return array;
}


// search same id symbols in same direction line, the result not include the symbol you passed
+(NSMutableArray*) searchSameLineSymbols: (SymbolView*)symbol direction:(APPDirection)direction
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity: 1];
    SymbolView* symbolGet = symbol;
    
    while (symbolGet) {
        symbolGet = [self getAdjacentSymbolByDirection: symbolGet direction:direction];
        if((symbol.prototype.identification == symbolGet.prototype.identification)) {
            [array addObject: symbolGet];
        } else {
            break;
        }
    }
    return array;
}





#pragma mark -

#pragma mark - GET



#pragma mark - Contains The Symbol You Passed

+(NSMutableArray*) getHorizontally: (SymbolView*)symbol
{
    if (!symbol) return nil;
    
    NSMutableArray* array = [self getSameLinesSymbols: symbol directions: DirectionRIGHT | DirectionLEFT];
    NSMutableArray* results = [ArrayHelper translateToOneDimension: array];
    [results addObject: symbol];
    return results;
}

+(NSMutableArray*) getVertically: (SymbolView*)symbol
{
    if (!symbol) return nil;
    
    NSMutableArray* array = [self getSameLinesSymbols: symbol directions: DirectionUP | DirectionDOWN];
    NSMutableArray* results = [ArrayHelper translateToOneDimension: array];
    [results addObject: symbol];
    return results;
}


#pragma mark - Not Contains The Symbol You Passed

// the result not include the symbol you passed
+(NSMutableArray*) getSameLinesSymbols: (SymbolView*)symbol directions:(APPDirection)directions
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity: 1];
    
    [self iterateDirections: directions handler:^BOOL(APPDirection direction) {
        NSMutableArray* results = [self getSameLineSymbols: symbol direction:direction];
        [array addObject: results];
        return NO;
    }];
    
    return array;
}


// the result not include the symbol you passed
+(NSMutableArray*) getSameLineSymbols: (SymbolView*)symbol direction:(APPDirection)direction
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity: 1];
    SymbolView* symbolGet = symbol;
    
    while (symbolGet) {
        symbolGet = [self getAdjacentSymbolByDirection: symbolGet direction:direction];
        if(symbolGet) [array addObject: symbolGet];
    }
    return array;
}












#pragma mark -

+(SymbolView*) getAdjacentSymbolByDirection: (SymbolView*)symbol start:(CGPoint)start end:(CGPoint)end {
    APPDirection direction = [self getDirectionBetween: start end:end];
    return [self getAdjacentSymbolByDirection: symbol direction:direction];
}

+(SymbolView*) getAdjacentSymbolByDirection: (SymbolView*)symbol direction:(APPDirection)direction
{
    if(! symbol) return nil;
    id obj = [self getAdjacentObjectByDirection: VIEW.gameView.symbolsInContainer row:symbol.row column:symbol.column direction:direction];
    return obj == [NSNull null] ? nil : obj;
}







#pragma mark - BASIC
+(float) getDegreeBetween:(CGPoint)p1 to:(CGPoint)p2 {
    float dx = p2.x - p1.x;
    float dy = p2.y - p1.y;
    float degree = (((atan2f(dx , dy))*180)/M_PI);
    return degree;
}

+(float) getRadianBetween:(CGPoint)p1 to:(CGPoint)p2 {
    float dx = p2.x - p1.x;
    float dy = p2.y - p1.y;
    float radains = atan2f(dx , dy);
    return radains;
}

+(APPDirection) getDirectionBetween: (CGPoint)start end:(CGPoint)end {
    float degree = [self getDegreeBetween: start to:end];
    return [self getDirectionByDegree: degree];
}

+(APPDirection) getDirectionByDegree: (float)degree {
    APPDirection direction = DirectionNONE;
    
    if (45.0 < degree && degree < 135.0) {
        direction = DirectionRIGHT;
    } else if ( -45.0 < degree && degree <= 45.0) {
        direction = DirectionDOWN;
    } else if ( -135.0 < degree && degree <= -45.0 ) {
        direction = DirectionLEFT;
    } else if ( degree <= -135.0 || degree >= 135.0 ) {
        direction = DirectionUP;
    }
    
    return direction;
}

+(APPDirection) getOppositeDirection: (APPDirection)direction {
    APPDirection result = DirectionNONE;
    
    if (direction == DirectionUPLEFT) {
        result = DirectionDOWNRIGHT;
    } else if (direction == DirectionUP) {
        result = DirectionDOWN;
    } else if (direction == DirectionUPRIGHT) {
        result = DirectionDOWNLEFT;
    } else if (direction == DirectionRIGHT) {
        result = DirectionLEFT;
    } else if (direction == DirectionDOWNRIGHT) {
        result = DirectionUPLEFT ;
    } else if (direction == DirectionDOWN) {
        result = DirectionUP;
    } else if (direction == DirectionDOWNLEFT) {
        result = DirectionUPRIGHT;
    } else if (direction == DirectionLEFT) {
        result = DirectionRIGHT;
    }
    return result;
}

+(NSMutableArray*) getAdjacentObjectsByDirections: (NSArray*)matrix row:(int)row column:(int)column directions:(APPDirection)directions
{
    NSMutableArray* results = [NSMutableArray array];
    
    [self iterateDirections:directions handler:^BOOL(APPDirection direction) {
        id obj = [self getAdjacentObjectByDirection: matrix row:row column:column direction:direction];
        if (obj) [results addObject: obj];
        return NO;
    }];
    
    return results;
}

+(void) iterateDirections: (APPDirection)directions handler:(BOOL(^)(APPDirection direction))handler
{
    if ((directions & DirectionUP) == DirectionUP) {
        if (handler(DirectionUP)) return;
    }
    if ((directions & DirectionRIGHT) == DirectionRIGHT) {
        if (handler(DirectionRIGHT)) return;
    }
    if ((directions & DirectionDOWN) == DirectionDOWN) {
        if (handler(DirectionDOWN)) return;
    }
    if ((directions & DirectionLEFT) == DirectionLEFT) {
        if (handler(DirectionLEFT)) return;
    }
    if ((directions & DirectionUPLEFT) == DirectionUPLEFT) {
        if (handler(DirectionUPLEFT)) return;
    }
    if ((directions & DirectionUPRIGHT) == DirectionUPRIGHT) {
        if (handler(DirectionUPRIGHT)) return;
    }
    if ((directions & DirectionDOWNRIGHT) == DirectionDOWNRIGHT) {
        if (handler(DirectionDOWNRIGHT)) return;
    }
    if ((directions & DirectionDOWNLEFT) == DirectionDOWNLEFT) {
        if (handler(DirectionDOWNLEFT)) return;
    }
}

+(void) iterateWholeDirections: (BOOL(^)(APPDirection direction))handler
{
    if (handler(DirectionUPLEFT)) return;
    if (handler(DirectionUP)) return;
    if (handler(DirectionUPRIGHT)) return;
    if (handler(DirectionRIGHT)) return;
    if (handler(DirectionDOWNRIGHT)) return;
    if (handler(DirectionDOWN)) return;
    if (handler(DirectionDOWNLEFT)) return;
    if (handler(DirectionLEFT)) return;
}

// just one direction , cause use 'if ... else ... ' , not 'if ... if ...'
+(id) getAdjacentObjectByDirection: (NSArray*)matrix row:(int)row column:(int)column direction:(APPDirection)direction
{
    NSUInteger outterCount = matrix.count ;
    if (row < 0 || row >= outterCount) return nil;
    NSUInteger innerCount = [[matrix objectAtIndex: row] count];
    if(column < 0 || column >= innerCount ) return nil;
    
    id adjacentObject = nil;
    if ((direction & DirectionUP) == DirectionUP) {
        if (row != 0){
            adjacentObject = [[matrix objectAtIndex: row - 1] objectAtIndex: column]; //up
        }
    } else if ((direction & DirectionRIGHT) == DirectionRIGHT) {
        if (column != innerCount - 1){
            adjacentObject = [[matrix objectAtIndex: row] objectAtIndex: column + 1]; //right
        }
    } else if ((direction & DirectionDOWN) == DirectionDOWN) {
        if (row != outterCount - 1){
            adjacentObject = [[matrix objectAtIndex: row + 1] objectAtIndex: column]; //down
        }
    } else if ((direction & DirectionLEFT) == DirectionLEFT) {
        if (column != 0){
            adjacentObject = [[matrix objectAtIndex: row] objectAtIndex: column - 1]; //left
        }
    } else if ((direction & DirectionUPLEFT) == DirectionUPLEFT) {
        if (row != 0 && column != 0){
            adjacentObject = [[matrix objectAtIndex: row - 1] objectAtIndex: column - 1]; //up left
        }
    } else if ((direction & DirectionUPRIGHT) == DirectionUPRIGHT) {
        if (row != 0 && column != innerCount - 1) {
            adjacentObject = [[matrix objectAtIndex: row - 1] objectAtIndex: column + 1]; //up right
        }
    } else if ((direction & DirectionDOWNRIGHT) == DirectionDOWNRIGHT) {
        if (row != outterCount -1 && column != innerCount - 1){
            adjacentObject = [[matrix objectAtIndex: row + 1] objectAtIndex: column + 1]; //down right
        }
    } else if ((direction & DirectionDOWNLEFT) == DirectionDOWNLEFT) {
        if (row != outterCount -1 && column != 0){
            adjacentObject = [[matrix objectAtIndex: row + 1] objectAtIndex: column - 1]; //down left
        }
    }
    return adjacentObject;
}

@end
