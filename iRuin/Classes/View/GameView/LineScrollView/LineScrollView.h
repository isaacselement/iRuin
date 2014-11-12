#import <UIKit/UIKit.h>


@class LineScrollView;
@class LineScrollViewCell;

@protocol LineScrollViewDataSource <NSObject>


@optional
// be sure that LineScrollView.width = cell.width * int
-(float)lineScrollView:(LineScrollView *)lineScrollView widthForCellAtIndex:(int)index;
-(BOOL)lineScrollView:(LineScrollView *)lineScrollView shouldShowIndex:(int)index;
-(void)lineScrollView:(LineScrollView *)lineScrollView willShowIndex:(int)index;
-(void)lineScrollView:(LineScrollView *)lineScrollView touchEndedAtPoint:(CGPoint)point;
-(void)lineScrollView:(LineScrollView *)lineScrollView touchBeganAtPoint:(CGPoint)point;


@end



@protocol LineScrollViewProxy <NSObject>

@optional

@end




@interface LineScrollView : UIScrollView


@property (assign) CGFloat eachCellWidth;   // should be CGFloat ! important !!! cause will raise the caculate problem

@property (assign, nonatomic) int currentIndex;


@property (strong, readonly) UIView* contentView;


@property (assign) id<LineScrollViewDataSource> dataSource;


@property (copy) float(^lineScrollViewWidthForCellAtIndex)(LineScrollView *lineScrollView, int index);
@property (copy) BOOL(^lineScrollViewShouldShowIndex)(LineScrollView *lineScrollView, int index);
@property (copy) void(^lineScrollViewWillShowIndex)(LineScrollView *lineScrollView, int index);
@property (copy) void(^lineScrollViewTouchEndedAtPoint)(LineScrollView *lineScrollView, CGPoint point);
@property (copy) void(^lineScrollViewTouchBeganAtPoint)(LineScrollView *lineScrollView, CGPoint point);





#pragma mark - Public Methods

-(void) registerCellClass:(Class)cellClass;

-(LineScrollViewCell*) visibleCellAtIndex: (int)index;

-(int) indexOfVisibleCell: (LineScrollViewCell*)cell;


@end
