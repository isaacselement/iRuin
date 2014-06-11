#import "BaseState.h"
#import "AppInterface.h"

@implementation BaseState

@synthesize effect;

#pragma mark - Subclass Override Methods
-(void) stateInitialize
{
}
-(void) stateTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    [effect effectTouchesBegan: symbol location:location];
}
-(void) stateTouchesMoved:(SymbolView*)symbol location:(CGPoint)location
{
    [effect effectTouchesMoved: symbol location:location];
}
-(void) stateTouchesEnded:(SymbolView*)symbol location:(CGPoint)location
{
    [effect effectTouchesEnded: symbol location:location];
}
-(void) stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    [effect effectTouchesCancelled: symbol location:location];
}



#pragma mark - Public Methods
// temp , need to be optimized
-(NSMutableArray*) ruinVanishedSymbols: (NSArray*)symbols
{
    NSMutableArray* nullRowColumns = [NSMutableArray array];
    NSArray* indexPathsRepository = QueueIndexPathParser.indexPathsRepository;
    NSArray* symbolsAtContainer = QueueViewsHelper.viewsInVisualArea;
    
    for (NSInteger i = 0; i < symbols.count; i++) {
        SymbolView* symbol = symbols[i];
        int row = symbol.row;
        int column = symbol.column;
        
        if (row == -1 || column == -1) {
            DLOG(@"ERROR!!! ---------- Vanish Error");
            continue;
        }
        
        [[symbolsAtContainer objectAtIndex: row] replaceObjectAtIndex: column withObject:[NSNull null]];
        [QueueViewsHelper.viewsReuseable addObject: symbol];
        
        [nullRowColumns addObject: [[indexPathsRepository objectAtIndex: row] objectAtIndex: column]];
    
        
        [symbol vanish];
    }
    return nullRowColumns;
}


-(void) stateStartNextPhase: (NSArray*)nullRowColumns
{
    [DATA.config[@"Squeeze"] boolValue] ? [self stateStartSqueeze: nullRowColumns] : [self stateStartAdjusts: nullRowColumns];
}

-(void) stateStartAdjusts: (NSArray*)nullRowColumns
{
    [effect effectStartAdjusts: nullRowColumns];
}

-(void) stateStartFillIn {
    [effect effectStartFillIn];
}

-(void) stateStartSqueeze: (NSArray*)nullRowColumns
{
    [effect effectStartSqueeze: nullRowColumns];
}

@end
