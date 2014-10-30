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
        lineScrollView.dataSource = self;
        lineScrollView.clipsToBounds = NO;
        [self addSubview: lineScrollView];
    }
    return self;
}

#pragma mark - LineScrollViewDataSource

-(void)lineScrollView:(LineScrollView *)lineScrollViewObj willShowIndex:(int)index
{
    LineScrollViewCell* cell = [lineScrollViewObj visibleCellAtIndex: index];
    
    [ColorHelper setBackGround: cell color: @(index % 5)];
    
//    int indexLableTag = 2010;
//    UILabel* indexLabel = (UILabel*)[cell viewWithTag: indexLableTag];
//    if (!indexLabel) {
//        indexLabel = [[UILabel alloc] initWithFrame: cell.bounds];
//        indexLabel.tag = indexLableTag;
//        [cell addSubview: indexLabel];
//        indexLabel.font = [UIFont fontWithName:@"Arial" size:CanvasFontSize(20)];
//        indexLabel.textAlignment = NSTextAlignmentCenter;
//        indexLabel.textColor = [UIColor blueColor];
//    }
//    indexLabel.frame = cell.bounds;
//    indexLabel.text = [NSString stringWithFormat:@"%d", index];
}

@end
