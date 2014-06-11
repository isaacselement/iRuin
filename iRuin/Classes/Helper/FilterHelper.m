#import "FilterHelper.h"
#import "AppInterface.h"

@implementation FilterHelper


// it semm has some problem ... need a long time to think ...
+(void) forwardFilterMatchedObjects {
    NSArray* symbolsAtContainer = VIEW.gameView.symbolsInContainer;
    for (int i = 0; i < symbolsAtContainer.count; i++) {
        NSArray* innerArray = [symbolsAtContainer objectAtIndex: i];
        for (int j = 0; j < innerArray.count; j++) {
            SymbolView* symbol = [innerArray objectAtIndex: j];
            [self forwardFilterPrototype: symbol currentIterateRow: &i currentIterateColumn:&j];
        }
    }
}

+(void) forwardFilterPrototype: (SymbolView*)symbol currentIterateRow:(int*)currentIterateRow currentIterateColumn:(int*)currentIterateColumn {
    if (! symbol || *currentIterateRow < 0 || *currentIterateColumn < 0) return;

    SymbolView* symbolUp = [SearchHelper getAdjacentSymbolByDirection: symbol direction: DirectionUP];
    SymbolView* symbolDown = [SearchHelper getAdjacentSymbolByDirection: symbol direction: DirectionDOWN];
    SymbolView* symbolLeft = [SearchHelper getAdjacentSymbolByDirection: symbol direction: DirectionLEFT];
    SymbolView* symbolRight = [SearchHelper getAdjacentSymbolByDirection: symbol direction: DirectionRIGHT];
    
    // check Vertical
    BOOL isVerSame = [self check: symbol second:symbolUp third:symbolDown];
    // check Horizontal
    BOOL isHorSame = [self check: symbol second:symbolRight third:symbolLeft];
    
    if (!isVerSame && !isHorSame) return;
    
    if (isVerSame && isHorSame) {
        [self setDifferentPrototype: symbol];

    } else if (isVerSame && !isHorSame) {
        [self setDifferentPrototype: symbolDown];
        
    } else if (!isVerSame && isHorSame) {
        [self setDifferentPrototype: symbolRight];
        
        SymbolView* symbolRightUp = [SearchHelper getAdjacentSymbolByDirection: symbolRight direction: DirectionUP];
        SymbolView* symbolRightUpUp = [SearchHelper getAdjacentSymbolByDirection: symbolRightUp direction: DirectionUP];
        BOOL isRIGHTUUSame = [self check: symbolRight second:symbolRightUp third:symbolRightUpUp];
        if (isRIGHTUUSame) {
            [self setDifferentPrototype: symbolRightUp];
            
            *currentIterateRow = *currentIterateRow - 1;
            *currentIterateColumn = *currentIterateColumn - 1;
            [self forwardFilterPrototype: symbolRightUp currentIterateRow:currentIterateRow currentIterateColumn:currentIterateColumn];
        }
    }
}


+(BOOL) check: (SymbolView*)symbol second:(SymbolView*)second third:(SymbolView*)third {
    if (!symbol || !second || !third) return false;
    int firstId = symbol.prototype.identification;
    int secondID = second.prototype.identification;
    int thirdID = third.prototype.identification;
    return firstId == secondID && firstId == thirdID;
}


+(void) setDifferentPrototype: (SymbolView*)symbolView {
    symbolView.prototype = [self getDifferentPrototype: symbolView];
}

+(Symbol*) getDifferentPrototype: (SymbolView*)symbolView {
    return [self getDifferentPrototypeByID: symbolView.prototype.identification];
}

+(Symbol*) getDifferentPrototypeByID: (int)identification {
    Symbol* prototype = [ACTION.gameState oneRandomPrototype];
    while (prototype.identification == identification) {
        prototype = [ACTION.gameState oneRandomPrototype];
    }
    return prototype;
}


@end
