#import "HeaderView.h"
#import "AppInterface.h"

@interface HeaderView () <LineScrollViewDataSource>

@end

@implementation HeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        LineScrollView* lineScrollView = [[LineScrollView alloc] init];
        lineScrollView.clipsToBounds = NO;
        lineScrollView.dataSource = self;
        [ColorHelper setBorder: lineScrollView];
        [self addSubview: lineScrollView];
    }
    return self;
}


#pragma mark - LineScrollViewDataSource

-(LineScrollViewCell *)lineScrollView:(LineScrollView *)lineScrollView cellAtIndex:(int)index
{
    LineScrollViewCell* cell = [[LineScrollViewCell alloc] init];
    return cell;
}


-(float)lineScrollView:(LineScrollView *)lineScrollView widthForCellAtIndex:(int)index
{
    return [FrameTranslater convertCanvasWidth: 120] ;
}


-(void)lineScrollView:(LineScrollView *)lineScrollView willShowIndex:(int)index
{
    LineScrollViewCell* cell = [lineScrollView visibleCellAtIndex: index];
    [ColorHelper setBackGround: cell color:[ColorHelper parseColor:@[@(index*2), @(index*8), @(index*10)]]];
}

-(BOOL)lineScrollView:(LineScrollView *)lineScrollView shouldShowIndex:(int)index
{
    if (index == 0) {
        return NO;
    }
    else if (index == 50) {
        return NO;
    }
    return YES;
}

@end
