#import "LineScrollView.h"
#import "LineScrollViewCell.h"

#import "ViewHelper.h"
#import "UIView+Frame.h"
#import "NSArray+Additions.h"



@implementation LineScrollView {
    Class __cellClass;

    float previousOffsetx;
    
//    int currentIndex;
    BOOL currentDirection;      // Yes : is heading right, currentIndex is decrease, contentOffset.x is decrease
}


@synthesize currentIndex;

@synthesize contentView;

@synthesize dataSource;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        contentView = [[UIView alloc] init];
        [self addSubview: contentView];
        
        __cellClass = [LineScrollViewCell class];
    
        self.delaysContentTouches = NO;             // call touchesBegan: immediately
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;

        [self addObserver: self forKeyPath:@"eachCellWidth" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
        
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aTapAction:)];
        [self addGestureRecognizer: gesture];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"eachCellWidth"]) {
        if ([change[@"old"] floatValue] != [change[@"new"] floatValue]) {
            [self reloadCells];
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    
    if (self.lineScrollViewTouchBeganAtPoint) {
        self.lineScrollViewTouchBeganAtPoint(self, location);
    } else if (dataSource && [dataSource respondsToSelector: @selector(lineScrollView:touchBeganAtPoint:)]) {
        [dataSource lineScrollView: self touchBeganAtPoint:location];
    }
}

/*
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    
    if (self.lineScrollViewTouchEndedAtPoint) {
        self.lineScrollViewTouchEndedAtPoint(self, location);
    } else if (dataSource && [dataSource respondsToSelector: @selector(lineScrollView:touchEndedAtPoint:)]) {
        [dataSource lineScrollView: self touchEndedAtPoint:location];
    }
}
*/

-(void) aTapAction: (UITapGestureRecognizer*)gesture
{
    CGPoint location = [gesture locationInView: gesture.view];
//    location = [gesture.view convertPoint: location toView:self];
    
    if (self.lineScrollViewTouchEndedAtPoint) {
        self.lineScrollViewTouchEndedAtPoint(self, location);
    } else if (dataSource && [dataSource respondsToSelector: @selector(lineScrollView:touchEndedAtPoint:)]) {
        [dataSource lineScrollView: self touchEndedAtPoint:location];
    }
}



-(void)setCurrentIndex:(int)index
{
    currentIndex = index;

    [self reloadCells];
}


-(void)setFrame:(CGRect)frame {
    
    if (CGRectEqualToRect(frame, self.frame)) {
        return;
    }
    
    // call super
    [super setFrame: frame];
    
    if (CGRectEqualToRect(frame, CGRectZero)) {
        return;
    }
    
    [self reloadCells];
}

-(void) reloadCells
{
    CGRect frame = self.frame;
    if (CGRectEqualToRect(frame, CGRectNull)) return;
        
    float width = frame.size.width;
    float height = frame.size.height;
    if (width == 0 || height == 0) return;
    
    
    // subviews are LineScrollViewCell
    NSArray* subviews = contentView.subviews;
    for (UIView* view in subviews) {
        [view removeFromSuperview];
    }

    currentDirection = NO;
    
    
    // begin
    int viewIndex = 0;
    float allCellsLength = 0.0f;
    CGFloat perCellWidth = self.eachCellWidth;
    int count = width / perCellWidth;
    int cellCount = count + 2;                      // need two to reuse
    currentIndex -= cellCount;
    for (int i = 0 ; i < cellCount; i++)
    {
        LineScrollViewCell* cell = [subviews safeObjectAtIndex: viewIndex];
        viewIndex++;
        if (! cell) {
            cell = [[__cellClass alloc] init];
        }
        
        cell.frame = CGRectMake(allCellsLength, 0, perCellWidth, height);
        [contentView addSubview: cell];
        
        allCellsLength += perCellWidth;
        
        // first call
        currentIndex++;
        if (self.lineScrollViewWillShowIndex) {
            self.lineScrollViewWillShowIndex(self, currentIndex, YES);
        } else if (dataSource && [dataSource respondsToSelector: @selector(lineScrollView:willShowIndex:isReload:)]) {
            [dataSource lineScrollView: self willShowIndex:currentIndex isReload:YES];
        }
    }
    
    self.contentSize = CGSizeMake(allCellsLength, height);
    contentView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    // check if change direction
    BOOL direction = self.contentOffset.x < previousOffsetx;
    if (currentDirection != direction) {
        NSUInteger count = contentView.subviews.count ;
        if (direction) {
            currentIndex -= (count - 1);
        } else {
            currentIndex += (count - 1);
        }
    }
    currentDirection = direction;
    
    // ask datasource
    int nextIndex = currentDirection ? currentIndex - 1 : currentIndex + 1;
    
    BOOL shouldShowNextIndex = YES;
    if (self.lineScrollViewShouldShowIndex) {
        shouldShowNextIndex = self.lineScrollViewShouldShowIndex(self, nextIndex);
    } else if (dataSource && [dataSource respondsToSelector:@selector(lineScrollView:shouldShowIndex:)]) {
        shouldShowNextIndex = [dataSource lineScrollView:self shouldShowIndex:nextIndex];
    }
    if (!shouldShowNextIndex) {
        return;
    }
    
    // if no return , check and do relocate if necessary.
    if (self.contentOffset.x != 0) [self relocateIfNecessary];
}

#pragma mark - Private Methods

// recenter content periodically to achieve impression of infinite scrolling
- (void)relocateIfNecessary
{
    // Forward Left
    if (self.contentOffset.x > self.eachCellWidth) {
        [self relocateSubviews: NO];
        
    // Forward Right
    } else if (self.contentOffset.x < 0 ) {
        [self relocateSubviews: YES];
    }
    previousOffsetx = self.contentOffset.x;
}

// isHeadRight means self.contentOffset.x is increasing!!!
-(void) relocateSubviews: (BOOL)isHeadingRight {
    if (isHeadingRight) {
        [self alignRight];
        currentIndex -- ;
    } else {
        [self reLeft];
        currentIndex ++ ;
    }

    // reset the x coordinate
    NSArray* subviews = contentView.subviews;       // subviews are LineScrollViewCell
    NSUInteger count = subviews.count;
    float xc[count] ;
    
    for (int i = 0; i < count; i++) {
        if (i == 0) xc[i] = [subviews[i] originX];
        else xc[i] = [subviews[i - 1] originX] + [subviews[i - 1] sizeWidth];
    }
    
    for (int i = 0; i < count; i++) {
        UIView* view = subviews[i];
        int j = isHeadingRight ?(i+1):(i-1);
        NSUInteger k = (j + count) % count;
        int x = xc[k];          // int will be better
        [view setOriginX: x];
    }
    
    // sort the subviews by x coordinate
    [ViewHelper sortedSubviewsByXCoordinate: contentView];
    
    
    // call delegate
    if (self.lineScrollViewWillShowIndex) {
        self.lineScrollViewWillShowIndex(self, currentIndex, NO);
    } else if (dataSource && [dataSource respondsToSelector: @selector(lineScrollView:willShowIndex:isReload:)]) {
        [dataSource lineScrollView: self willShowIndex:currentIndex isReload:NO];
    }
}

#pragma mark - Public Methods

-(void) registerCellClass:(Class)cellClass
{
    __cellClass = cellClass;
}

-(LineScrollViewCell *)visibleCellAtIndex:(int)index
{
    return [contentView.subviews safeObjectAtIndex: (index - [self mostLeftIndex])];
}

-(int) indexOfVisibleCell: (LineScrollViewCell*)cell
{
    return (int)[contentView.subviews indexOfObject: cell] + [self mostLeftIndex];
}


-(int) mostLeftIndex
{
    int mostLeftIndex = currentDirection ? currentIndex : currentIndex - ((int)contentView.subviews.count - 1) ;
    return mostLeftIndex;
}



-(void) alignRight
{
    self.contentOffset = CGPointMake(self.eachCellWidth, self.contentOffset.y);
}

#pragma mark -

-(void) reLeft {
    self.contentOffset = CGPointMake(0, self.contentOffset.y);
}
-(void) reRight {
    self.contentOffset = CGPointMake(self.contentSize.width - self.bounds.size.width, self.contentOffset.y);
}
-(void) reCenter {
    self.contentOffset = CGPointMake((self.contentSize.width - self.bounds.size.width)/2, self.contentOffset.y);
}


@end
