#import "LineScrollView.h"
#import "LineScrollViewCell.h"

#import "UIView+PropertiesSetter.h"

#import "Modules.h"         // Remove it when complete

#define default_cell_width 80.0f;


@implementation LineScrollView {
    float criticalWidth;

    float previousOffsetx;
    int criticalIndex;      // the head or the tail
    
    
    BOOL currentDirection;
    int currentIndex;
}

@synthesize dataSource;

@synthesize contentView;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        contentView = [[UIView alloc] init];
        [self addSubview: contentView];
    
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    // check if change direction
    BOOL direction = self.contentOffset.x < previousOffsetx;
    if ([self getRightestIndexCellWidth] || previousOffsetx != 0) {
        if (currentDirection != direction) [self directionDidChange: direction];
    }
    currentDirection = direction;
    
    // ask datasource
    int nextIndex = currentDirection ? currentIndex- 1 : currentIndex + 1;
    if (dataSource && [dataSource respondsToSelector:@selector(lineScrollView:shouldShowIndex:)]) {
        if (! [dataSource lineScrollView:self shouldShowIndex:nextIndex]) {
            return;
        }
    }
    
    // if no return , check and do relocate if necessary.
    if (self.contentOffset.x != 0) [self relocateIfNecessary];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame: frame];
    float width = frame.size.width;
    float height = frame.size.height;
    if (width == 0 || height == 0) return;

    float length = 0.0f;
    for ( ; (length - width) < [self getCellWidth: criticalIndex + 1] ; )
    {
        LineScrollViewCell* cell = [self getCell: criticalIndex];
        
        if (! cell) break ; // aware of the infinite loop
        
        float cellWidth = [cell getSizeWidth];
        
        cell.frame = CGRectMake(length, 0, cellWidth, height);
        criticalIndex++;
        
        [contentView addSubview: cell];
        
        length += cellWidth;
        
        
        // first call
        currentIndex = criticalIndex;
        if (dataSource && [dataSource respondsToSelector: @selector(lineScrollView:willShowIndex:)]) {
            [dataSource lineScrollView: self willShowIndex:currentIndex];
        }
    }
    
    criticalWidth = [self getLeftestIndexCellWidth];
    
    float lineLength = 0.0f;
    for (UIView* view in contentView.subviews)  lineLength += [view getSizeWidth];
    self.contentSize = CGSizeMake(lineLength, height);
    contentView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
}

#pragma mark - Private Methods

// recenter content periodically to achieve impression of infinite scrolling
- (void)relocateIfNecessary
{
    // Forward Left
    if (self.contentOffset.x > criticalWidth) {
        [self relocateSubviews: NO];
        criticalWidth = [self getLeftestIndexCellWidth];
        
    // Forward Right
    } else if (self.contentOffset.x < 0 ) {
        [self relocateSubviews: YES];
    }
    previousOffsetx = self.contentOffset.x;
    
}

-(void) alignRight
{
    self.contentOffset = CGPointMake([self getRightestIndexCellWidth], self.contentOffset.y);
}

-(void) directionDidChange: (BOOL)isHeadRight {
    NSLog(@"directionDidChange - %d" , isHeadRight);
    NSUInteger count = contentView.subviews.count ;
    if (isHeadRight) {
        criticalIndex -= (count + 1);
        currentIndex -= (count - 1);
    } else {
        criticalIndex += (count + 1);
        currentIndex += (count - 1);
    }
}

// isHeadRight means self.contentOffset.x is increasing!!!
-(void) relocateSubviews: (BOOL)isHeadRight {
    if (isHeadRight) {
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
        if (i == 0) xc[i] = [subviews[i] getOriginX];
        else xc[i] = [subviews[i - 1] getOriginX] + [subviews[i - 1] getSizeWidth];
    }
    
    for (int i = 0; i < count; i++) {
        UIView* view = subviews[i];
        int j = isHeadRight ?(i+1):(i-1);
        NSUInteger k = (j + count) % count;
        [view setOriginX: xc[k]];
    }
    
    // sort the subview by x coordinate
    [ViewHelper sortedSubviewsByXCoordinate: contentView];
    
    
    // call delegate
    if (dataSource && [dataSource respondsToSelector: @selector(lineScrollView:willShowIndex:)]) {
        [dataSource lineScrollView: self willShowIndex:currentIndex];
    }
}

-(LineScrollViewCell*) getCell: (int)index
{
    float cellWidth = [self getCellWidth: index];
    LineScrollViewCell* cell = [dataSource lineScrollView: self cellAtIndex: index];
    [cell setSizeWidth: cellWidth];
    return cell;
}

-(float) getCellWidth: (int)index
{
    float cellWidth = default_cell_width ;
    if (dataSource && [dataSource respondsToSelector:@selector(lineScrollView:widthForCellAtIndex:)]) {
       cellWidth = [dataSource lineScrollView: self widthForCellAtIndex: index];
    }
    return cellWidth;
}

-(float) getLeftestIndexCellWidth
{
    return [self getCellWidth: criticalIndex - (int)contentView.subviews.count];
}

-(float) getRightestIndexCellWidth
{
    return [self getCellWidth: criticalIndex - 1];
}


#pragma mark - Public Methods
-(LineScrollViewCell *)visibleCellAtIndex:(int)index
{
    NSArray* cells = contentView.subviews;
    int mostLeftIndex = currentDirection ? currentIndex : currentIndex - ((int)cells.count - 1) ;
    return [contentView.subviews objectAtIndex: (index - mostLeftIndex)];
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
