#import <Foundation/Foundation.h>

@interface PositionsHelper : NSObject


+(NSMutableArray*) getIndexPathsNullInVisualAreaViews;


+(void) updateAdjustRowsColumnsInVisualArea: (NSMutableArray*)viewsSequence;
+(void) updateFillInRowsColumnsInVisualArea: (NSMutableArray*)viewsSequence;


+(void) updateRollInRowsColumnsInVisualArea: (NSMutableArray*)viewsSequence;
+(void) updateRollOutRowsColumnsInVisualArea: (NSMutableArray*)viewsSequence;


+(void) updateRowsColumnsInVisualArea: (NSArray*)oneDimensionSymbols;


@end
