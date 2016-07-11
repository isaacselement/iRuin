#import <Foundation/Foundation.h>

@interface PositionsHelper : NSObject

+(void) replaceOutdatedPositionsWithNullInVisualArea: (NSArray*)oneDimensionSymbols;

+(void) updateRowsColumnsInVisualArea: (NSArray*)oneDimensionSymbols;


@end
