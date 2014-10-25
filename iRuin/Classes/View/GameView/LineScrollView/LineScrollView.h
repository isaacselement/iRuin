#import <UIKit/UIKit.h>


@class LineScrollView;
@class LineScrollViewCell;

@protocol LineScrollViewDataSource <NSObject>


@optional
// be sure that LineScrollView.width = cell.width * int
-(float)lineScrollView:(LineScrollView *)lineScrollView widthForCellAtIndex:(int)index;
-(void)lineScrollView:(LineScrollView *)lineScrollView willShowIndex:(int)index;
-(BOOL)lineScrollView:(LineScrollView *)lineScrollView shouldShowIndex:(int)index;
-(void)lineScrollView:(LineScrollView *)lineScrollView didSelectIndex:(int)index;

@end



@protocol LineScrollViewProxy <NSObject>

@optional

@end




@interface LineScrollView : UIScrollView

@property (nonatomic, assign) id<LineScrollViewDataSource> dataSource;


@property (strong, readonly) UIView* contentView;



#pragma mark - Public Methods

-(void) registerCellClass:(Class)cellClass;

-(LineScrollViewCell*) visibleCellAtIndex: (int)index;

-(int) indexOfVisibleCell: (LineScrollViewCell*)cell;


@end
