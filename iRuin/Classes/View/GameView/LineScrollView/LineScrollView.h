#import <UIKit/UIKit.h>


@class LineScrollView;
@class LineScrollViewCell;

@protocol LineScrollViewDataSource <NSObject>

@required
- (LineScrollViewCell *)lineScrollView:(LineScrollView *)lineScrollView cellAtIndex:(int)index;


@optional
// be sure that LineScrollView.width = cell.width * int
-(float)lineScrollView:(LineScrollView *)lineScrollView widthForCellAtIndex:(int)index;
-(void)lineScrollView:(LineScrollView *)lineScrollView willShowIndex:(int)index;
-(BOOL)lineScrollView:(LineScrollView *)lineScrollView shouldShowIndex:(int)index;

@end



@protocol LineScrollViewProxy <NSObject>

@optional

@end




@interface LineScrollView : UIScrollView

@property (nonatomic, assign) id<LineScrollViewDataSource> dataSource;

@property (strong, readonly) UIView* contentView;



-(LineScrollViewCell*) visibleCellAtIndex: (int)index;


@end
