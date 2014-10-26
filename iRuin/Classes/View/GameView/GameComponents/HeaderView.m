#import "HeaderView.h"
#import "AppInterface.h"

@interface HeaderView () <LineScrollViewDataSource>

@end

@implementation HeaderView


@synthesize lineScrollView;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        lineScrollView = [[LineScrollView alloc] init];
        lineScrollView.clipsToBounds = NO;
        lineScrollView.dataSource = self;
        [ColorHelper setBorder: lineScrollView];
        
        [self addSubview: lineScrollView];
    }
    return self;
}

#pragma mark - LineScrollViewDataSource

-(float)lineScrollView:(LineScrollView *)lineScrollView widthForCellAtIndex:(int)index
{
    return [FrameTranslater convertCanvasWidth: 120] ;
}


-(void)lineScrollView:(LineScrollView *)lineScrollViewObj willShowIndex:(int)index
{
    LineScrollViewCell* cell = [lineScrollViewObj visibleCellAtIndex: index];
    [ColorHelper setBackGround: cell color:[ColorHelper parseColor:@[@(index*2), @(index*8), @(index*10)]]];
    
    
    int indexLableTag = 2010;
    UILabel* indexLabel = (UILabel*)[cell viewWithTag: indexLableTag];
    if (!indexLabel) {
        indexLabel = [[UILabel alloc] initWithFrame: cell.bounds];
        indexLabel.tag = indexLableTag;
        [cell addSubview: indexLabel];
    }
    indexLabel.text = [NSString stringWithFormat:@"%d", index];
    indexLabel.font = [UIFont fontWithName:@"Arial" size:CanvasFontSize(20)];
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
}

@end
