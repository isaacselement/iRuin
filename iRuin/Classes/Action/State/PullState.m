#import "PullState.h"
#import "AppInterface.h"



#define shift_direction_nimidistance (5)



@implementation PullState
{
    SymbolView* touchingSymbol;
    
    CGFloat gap;
    
    CGPoint startPoint;
    BOOL isCheckDirection;
    
    
    BOOL isVertical;
    NSMutableArray* currentMovingViews;         // one of the following two
    NSMutableArray* currentVerticalViews;       // the touching symbol's vertical views
    NSMutableArray* currentHorizontalViews;     // the touching symbol's horizontal views
    
    
    int interval;
    
    CGFloat xDistance;
    CGFloat yDistance;
    
    
    NSMutableArray* _operatingViews;            // for reuse the two views
    
    NSMutableArray* _originalPositions;         // currentMovingViews's original positions
}


#pragma mark - Override Methods

-(void) stateInitialize
{
    [super stateInitialize];
    
    NSArray* positionsRepository = [QueuePositionsHelper positionsRepository];
    CGPoint center = [[[positionsRepository firstObject] safeObjectAtIndex:0] CGPointValue];
    CGPoint xCenter = [[[positionsRepository firstObject] safeObjectAtIndex:1] CGPointValue];
    CGPoint yCenter = [[[positionsRepository safeObjectAtIndex: 1] safeObjectAtIndex:0] CGPointValue];
    
    xDistance = xCenter.x - center.x;
    yDistance = yCenter.y - center.y;
}

- (void)stateTouchesBegan:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesBegan:symbol location:location];
    
    // when the symbols is vanishing , adjusting , filling , squeezing ...
    if (self.isSymbolsOnVAFSing) {
        return;
    }
    
    touchingSymbol = symbol;
    currentMovingViews = nil;
    
    startPoint = location;
    isCheckDirection = NO;
    
    
    // views
    currentVerticalViews = [SearchHelper getVertically: symbol];
    if (currentVerticalViews.count == 0) currentVerticalViews = nil;
    currentHorizontalViews = [SearchHelper getHorizontally: symbol];
    if (currentHorizontalViews.count == 0) currentHorizontalViews = nil;

    // sort
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
    
    if (! touchingSymbol) return;
    
        
    if (! isCheckDirection) {
        [self checkDirection: location];
    } else {
        
        if(! currentMovingViews) return;
        
        if (isVertical) {

            float y = location.y - gap;
            for (SymbolView* symbol in currentMovingViews) {
                symbol.center = CGPointMake(symbol.center.x, symbol.center.y + y );
            }
            gap = location.y;
            
            
            float length = location.y - startPoint.y;
            
            // -----------------------------
            int value = length / yDistance;
            if (interval == value) return;
            [self.effect effectTouchesMoved:touchingSymbol location:location];
            [self setInterval: value];
            
            
        } else {

            float x = location.x - gap;
            for (SymbolView* symbol in currentMovingViews) {
                symbol.center = CGPointMake(symbol.center.x + x, symbol.center.y);
            }
            gap = location.x;
            
            
            float length = location.x - startPoint.x;
            
            // -----------------------------
            int value = length / xDistance;
            if (interval == value) return;
            [self.effect effectTouchesMoved:touchingSymbol location:location];
            [self setInterval: value];
        }
    }
}

- (void)stateTouchesEnded:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesEnded:symbol location:location];
    
    if (!touchingSymbol || !currentMovingViews) return;
    touchingSymbol = nil;
    
    // To the appropriate positions, and set the right row column
    [self adjustMovingViewsPositions: NO];
    [PositionsHelper updateRowsColumnsInVisualArea: [StateHelper getViewsInContainer: currentMovingViews]];
    
    // after update row and column
    NSMutableArray* vanishSymbols = [SearchHelper searchMatchedInAllLines: MATCH_COUNT];
    [self.effect effectStartVanish: vanishSymbols];
}

- (void)stateTouchesCancelled:(SymbolView*)symbol location:(CGPoint)location
{
    [super stateTouchesCancelled:symbol location:location];
    
    if (!touchingSymbol || !currentMovingViews) return;
    touchingSymbol = nil;
    
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
        gap = isVertical ? startPoint.y : startPoint.x;
        
        // get the direction , then prepare the moving views
        currentMovingViews = isVertical ? currentVerticalViews : currentHorizontalViews;
        SymbolView* first = [currentMovingViews firstObject];
        SymbolView* last = [currentMovingViews lastObject];
        
        if (!first || !last) return;
        
        
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
    return [QueueViewsHelper getUselessViews: 2];
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
        
        // for the two useless symbols
        if (index == 0 || index == count - 1) {
            [((SymbolView*)obj) setCenter: VIEW.frame.blackPoint];
            
            return NO;
        }
        
        // a phone call come in or something happened ...
        if (isCancel) {
            
            [((SymbolView*)obj) setCenter: [pointValue CGPointValue]];
            
        } else {
            
            SymbolView* symbol = (SymbolView*)obj;
            NSArray* symbolPositions = @[CGPointValue(symbol.center), pointValue];
            
            [symbol.layer setValue:pointValue forKey:@"position"]; // for the config is nil or no 'position' executor
            
            [VIEW.actionExecutorManager runActionExecutors:DATA.config[@"Adjust_Positions_ActionExecutors"] onObjects:@[obj] values:symbolPositions baseTimes:nil];
        }
        
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
    
    int identification = [SymbolView getOneRandomSymbolIdentification];
    if (!isRandom) {
        NSUInteger againstIndex = isFirstView ? currentMovingViews.count - 2 : 1 ;
        SymbolView* againstView = [currentMovingViews objectAtIndex: againstIndex];
        identification = againstView.identification;
    }
    view.identification = identification;
}

@end
