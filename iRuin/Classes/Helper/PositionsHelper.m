#import "PositionsHelper.h"
#import "AppInterface.h"

@implementation PositionsHelper

#pragma mark - Public Methods

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
    NSArray* viewsInVisualArea = QueueViewsHelper.viewsInVisualArea;
    for (int i = 0; i < viewsInVisualArea.count; i++) {
        NSMutableArray* innerArray = [viewsInVisualArea objectAtIndex: i];
        if (! [innerArray containsObject: symbolObj]) continue;
        
        for (int j = 0; j < innerArray.count; j++) {
            SymbolView* symbol = [innerArray objectAtIndex: j];
            if (symbolObj == symbol) {
                [innerArray replaceObjectAtIndex: j withObject:[NSNull null]];
                return;
            }
        }
    }
}

// reset the row column properties
+(void) updateRowsColumnsInVisualArea: (NSArray*)oneDimensionSymbols
{
    for (SymbolView* symbolObj in oneDimensionSymbols) {
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
                if (i < [viewsInVisualArea count]) {
                    if (j < [viewsInVisualArea[i] count]) {
                        symbol.row = i;
                        symbol.column = j;
                        [[viewsInVisualArea objectAtIndex: i] replaceObjectAtIndex: j withObject:symbol];
                    }
                }
                return;
            }
        }
    }
}

@end
