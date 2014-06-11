#import "PositionsHelper.h"
#import "AppInterface.h"

@implementation PositionsHelper

#pragma mark - Public Methods

+(NSMutableArray*) getIndexPathsNullInVisualAreaViews
{
    return [QueueIndexPathParser getIndexPathsIn: QueueViewsHelper.viewsInVisualArea element:[NSNull null]];
}


+(void) updateAdjustRowsColumnsInVisualArea: (NSMutableArray*)viewsSequence
{
    NSMutableArray* onedimensionViews =[self translateToOneDimensionAndRemoveTheNull:viewsSequence];
    // replace the original location symbol (just a copy) with null
    [self replaceOutdatedPositionsWithNullInVisualArea: onedimensionViews];
    // reset the row column properties
    [self updateRowsColumnsInVisualArea: onedimensionViews];
}

+(void) updateFillInRowsColumnsInVisualArea: (NSMutableArray*)viewsSequence
{
    NSMutableArray* onedimensionViews =[self translateToOneDimensionAndRemoveTheNull:viewsSequence];
    // reset the row column properties
    [self updateRowsColumnsInVisualArea: onedimensionViews];
}

+(NSMutableArray*) translateToOneDimensionAndRemoveTheNull: (NSMutableArray*)viewsSequence
{
    // translate to one dimension array .
    // remove the [NSNull null] single instance
    NSMutableArray* onedimensionViews = [ArrayHelper translateToOneDimension: viewsSequence];
    [onedimensionViews removeObject:[NSNull null]];
    return onedimensionViews;
}



#pragma mark -

// replace the original location symbol with null
+(void) replaceOutdatedPositionsWithNullInVisualArea: (NSArray*)oneDimensionSymbols
{
    for (SymbolView* symbolObj in oneDimensionSymbols) {
        [self replaceOutdatedPositionWithNullInVisualArea: symbolObj];
    }
}
// symbolObj was move to new position, then its old position use null to feed .
+(void) replaceOutdatedPositionWithNullInVisualArea: (SymbolView*)symbolObj
{
//    DLog(@"row column : %d,%d", symbolObj.row, symbolObj.column);
    NSArray* viewsInVisualArea = QueueViewsHelper.viewsInVisualArea;
    for (int i = 0; i < viewsInVisualArea.count; i++) {
        NSMutableArray* innerArray = [viewsInVisualArea objectAtIndex: i];
        if (! [innerArray containsObject: symbolObj]) continue;
        for (int j = 0; j < innerArray.count; j++) {
            SymbolView* symbol = [innerArray objectAtIndex: j];
            if (symbolObj == symbol) {
                [innerArray replaceObjectAtIndex: j withObject:[NSNull null]];
//                DLog(@"i j : %d,%d", i, j);
                return;
            }
        }
    }
}

// reset the row column properties
+(void) updateRowsColumnsInVisualArea: (NSArray*)oneDimensionObjects
{
    for (NSUInteger k = 0; k < oneDimensionObjects.count; k++) {
        SymbolView* symbolObj = oneDimensionObjects[k];
        [self updateRowColumnInVisualArea: symbolObj];
    }
}
+(void) updateRowColumnInVisualArea: (SymbolView*)symbol
{
    if (!symbol || (id)symbol == [NSNull null]) return;
    CGPoint center = symbol.center;
    
    NSArray* viewsInVisualArea = QueueViewsHelper.viewsInVisualArea;
    NSArray* rectsRepository = QueuePositionsHelper.rectsRepository;
    for (int i = 0 ; i < rectsRepository.count ; i++) {
        NSArray* innerRects = [rectsRepository objectAtIndex: i];
        for (int j = 0 ; j < innerRects.count ; j++) {
            
            CGRect rect = [[innerRects objectAtIndex: j] CGRectValue];
            if ([QueuePositionsHelper isPointInclude: center inRect:rect]) {
                symbol.row = i;
                symbol.column = j;
                [[viewsInVisualArea objectAtIndex: i] replaceObjectAtIndex: j withObject:symbol];
                return;
            }
        }
    }
}

@end
