#import "PullState.h"
#import "AppInterface.h"



#define shift_direction_nimidistance (5)



@implementation PullState
{
    SymbolView* touchingSymbol;
    
    
    CGFloat offsetX ;
    CGFloat offsetY ;
    CGPoint startPoint;
    BOOL isCheckDirection;
    
    
    BOOL isVertical;
    NSMutableArray* currentMovingViews;         // one of the following two
    NSMutableArray* currentVerticalViews;       // the touching symbol's vertical views
    NSMutableArray* currentHorizontalViews;     // the touching symbol's horizontal views
    
    
    NSMutableArray* _operatingViews;            // for reuse the two views
    
    
    int interval;
    
    CGFloat xDistance;
    CGFloat yDistance;

    
    NSMutableArray* _originalPositions;
}


#pragma mark - Override Methods

-(void) stateInitialize
{
    [super stateInitialize];
    
    SymbolView* symbol = [[VIEW.gameView.symbolsInContainer firstObject] firstObject];
    SymbolView* xSymbol = [SearchHelper getAdjacentSymbolByDirection: symbol direction:DirectionRIGHT];
    SymbolView* ySymbol = [SearchHelper getAdjacentSymbolByDirection: symbol direction:DirectionDOWN];
    
    xDistance = [xSymbol centerX] - [symbol centerX];
    yDistance = [ySymbol centerY] - [symbol centerY];
    
}

- (void)stateTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesBegan:symbol location:location];
    
    // When the symbol is nil situation
    
    touchingSymbol = symbol;
    
    
    offsetX = location.x - symbol.center.x;
    offsetY = location.y - symbol.center.y;
    startPoint = location;
    isCheckDirection = NO;
    
    
    // views
    currentVerticalViews = [SearchHelper getVertically: symbol];
    currentHorizontalViews = [SearchHelper getHorizontally: symbol];
    [currentHorizontalViews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UIView* view1 = (UIView*)obj1;
        UIView* view2 = (UIView*)obj2;
        float view1X = view1.frame.origin.x;
        float view2X = view2.frame.origin.x;
        return [[NSNumber numberWithFloat: view1X] compare: [NSNumber numberWithFloat: view2X]];
    }];
    [currentVerticalViews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UIView* view1 = (UIView*)obj1;
        UIView* view2 = (UIView*)obj2;
        float view1Y = view1.frame.origin.y;
        float view2Y = view2.frame.origin.y;
        return [[NSNumber numberWithFloat: view1Y] compare: [NSNumber numberWithFloat: view2Y]];
    }];
    
    
    interval = 0;
}

- (void)stateTouchesMoved:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesMoved:symbol location:location];
    
    if (! isCheckDirection) {
        [self checkDirection: location];
    } else {
        if (! currentMovingViews) return;
        
        
        if (isVertical) {

            float y = location.y - touchingSymbol.center.y - offsetY;
            for (SymbolView* symbol in currentMovingViews) {
                symbol.center = CGPointMake(symbol.center.x, symbol.center.y + y );
            }
            
            
            float length = location.y - startPoint.y;
            
            [self setInterval: length / yDistance];
            
            
            
        } else {

            float x = location.x - touchingSymbol.center.x - offsetX;
            for (SymbolView* symbol in currentMovingViews) {
                symbol.center = CGPointMake(symbol.center.x + x, symbol.center.y);
            }
            
            
            float length = location.x - startPoint.x;
            
            [self setInterval: length / xDistance];
        }
    }
}

- (void)stateTouchesEnded:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesEnded:symbol location:location];
    
    
    // To the appropriate positions, and set the right row column
    [self adjustMovingViewsPositions: NO];
    [PositionsHelper updateRowsColumnsInVisualArea: [StateHelper getViewsInContainer: currentMovingViews]];
    
    // after update row and column
    NSMutableArray* vanishSymbols = [SearchHelper searchMatchedInAllSymbols];
    if (vanishSymbols) [self.effect effectStartVanish: vanishSymbols];
}

- (void)stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesCancelled:symbol location:location];
    
    // To the appropriate positions, and set the right row column
    [self adjustMovingViewsPositions: YES];
    [PositionsHelper updateRowsColumnsInVisualArea: [StateHelper getViewsInContainer: currentMovingViews]];
}



#pragma mark - Private Methods

-(void) checkDirection: (CGPoint)location {
    float distanceX = location.x - startPoint.x;
    float distanceY = location.y - startPoint.y;
    double distanceMove = sqrt((distanceX * distanceX) + (distanceY * distanceY));
    if (distanceMove >= shift_direction_nimidistance) {
        isCheckDirection = YES;
        isVertical = fabsf(distanceY) > fabsf(distanceX) ;
        
        
        // get the direction , then prepare the moving views
        currentMovingViews = isVertical ? currentVerticalViews : currentHorizontalViews;
        SymbolView* first = [currentMovingViews firstObject];
        SymbolView* last = [currentMovingViews lastObject];
        
        
        // the two additional views
        NSArray* twoViews = [self getTwoUselessViews];
        SymbolView* firstView = [twoViews firstObject];
        SymbolView* lastView = [twoViews lastObject];
        // positions
        if (isVertical) {
            firstView.center = CGPointMake([first centerX], [first centerY] - yDistance);
            lastView.center = CGPointMake([last centerX], [last centerY] + yDistance);
        } else {
            firstView.center = CGPointMake([first centerX] - xDistance, [first centerY]);
            lastView.center = CGPointMake([last centerX] + xDistance, [last centerY]);
        }
        
        [currentMovingViews insertObject: firstView atIndex:0];
        [currentMovingViews addObject: lastView];
        
        [self updateFirstViewPrototypes];
        [self updateLastViewPrototypes];
        
        // prepare the origin positions
        [self setOriginalViewPositions: currentMovingViews];
    }
}

-(NSArray*) getTwoUselessViews
{
    if (! _operatingViews) {
        _operatingViews = [NSMutableArray array];
        [IterateHelper iterate: VIEW.gameView.symbolsInContainer handler:^BOOL(int index, id obj, int count) {
            [_operatingViews addObjectsFromArray: obj];
            return NO;
        }];
        NSArray* twoUselessViews = [QueueViewsHelper getUselessViews: 2];
        [_operatingViews addObjectsFromArray: twoUselessViews];
    }
    
    NSMutableArray* results = [NSMutableArray arrayWithArray: _operatingViews];
    [IterateHelper iterateTwoDimensionArray:VIEW.gameView.symbolsInContainer handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
        [results removeObject: obj];
        return NO;
    }];
    
    return results;
}


-(void) setOriginalViewPositions: (NSArray*)views
{
    if (! _originalPositions) {
        _originalPositions = [NSMutableArray array];
    }
    
    [_originalPositions removeAllObjects];
    [IterateHelper iterate: views handler:^BOOL(int index, id obj, int count) {
        [_originalPositions addObject: [NSValue valueWithCGPoint: ((UIView*)obj).center]];
        return NO;
    }];
}


// When touch moving
-(void) setInterval: (int)value
{
    if (interval == value) return;
    
    int count = abs(interval - value);
    for (int i = 0; i < count; i++) {
        
        SymbolView* first = [currentMovingViews firstObject];
        SymbolView* last = [currentMovingViews lastObject];
        
        if (interval < value) {
            if (isVertical) {   // pulling down
                [last setCenterY: [first centerY] - yDistance];
                [currentMovingViews moveLastObjectToFirst];
                [self updateFirstViewPrototypes];
            } else {            // pulling right
                [last setCenterX: [first centerX] - xDistance];
                [currentMovingViews moveLastObjectToFirst];
                [self updateFirstViewPrototypes];
            }
        } else {
            if (isVertical) {   // pulling up
                [first setCenterY: [last centerY] + yDistance];
                [currentMovingViews moveFirstObjectToLast];
                [self updateLastViewPrototypes];
            } else {            // pulling left
                [first setCenterX: [last centerX] + xDistance];
                [currentMovingViews moveFirstObjectToLast];
                [self updateLastViewPrototypes];
            }
        }
        
    }
    
    interval = value;
}


// Adjust positions when touch end
-(void) adjustMovingViewsPositions: (BOOL)isCancel
{
    NSMutableArray* views = [NSMutableArray arrayWithArray: currentMovingViews];
    
    // a phone call come in or something happened ...
    if (isCancel) {
        [IterateHelper iterate: views handler:^BOOL(int index, id obj, int count) {
            [(UIView*)obj setCenter: [[_originalPositions safeObjectAtIndex: index] CGPointValue]];
            return NO;
        }];
        return;
    }
    
    // else ...
    
    SymbolView* first = [views firstObject];
    SymbolView* last = [views lastObject];
    if (![StateHelper isInContainer: first] && ![StateHelper isInContainer: last]) {
        
        // Do nothing ...
        
    } else if ([StateHelper isInContainer: first]) {
        
        if (isVertical) {
            [last setCenterY: [first centerY] - yDistance];
            [views moveLastObjectToFirst];
        } else {
            [last setCenterX: [first centerX] - xDistance];
            [views moveLastObjectToFirst];
            
        }
        
    } else if ([StateHelper isInContainer: last]) {
        
        if (isVertical) {
            [first setCenterY: [last centerY] + yDistance];
            [views moveFirstObjectToLast];
        } else {
            [first setCenterX: [last centerX] + xDistance];
            [views moveFirstObjectToLast];
        }
        
    }
    
    [IterateHelper iterate: views handler:^BOOL(int index, id obj, int count) {
        NSValue* pointValue = [_originalPositions safeObjectAtIndex: index];
        NSArray* symbolPositions = @[CGPointValue(((UIView*)obj).center), pointValue];
        [VIEW.actionExecutorManager runActionExecutors:DATA.config[@"Adjust_Positions_ActionExecutors"] onObjects:@[obj] values:symbolPositions baseTimes:nil];
        return NO;
    }];
}




// About Prototypes
-(void) updateFirstViewPrototypes
{
    [self updateViewPrototypeAfterAdjustIndex: YES];
}

-(void) updateLastViewPrototypes
{
    [self updateViewPrototypeAfterAdjustIndex: NO];
}
-(void) updateViewPrototypeAfterAdjustIndex: (BOOL)isFirstView
{
    SymbolView* view = isFirstView ? [currentMovingViews firstObject] : [currentMovingViews lastObject];
    BOOL isRandom = [DATA.config[@"IsRandom"] boolValue];           // random or not
    
    Symbol* prototype = nil;
    if (isRandom) {
        prototype = [ACTION.gameState oneRandomPrototype];
    } else {
        NSUInteger againstIndex = isFirstView ? currentMovingViews.count - 2 : 1 ;
        SymbolView* againstView = [currentMovingViews objectAtIndex: againstIndex];
        prototype = againstView.prototype;
    }
    view.prototype = prototype;
}

@end
