#import "ChaptersView.h"
#import "AppInterface.h"

@interface ChaptersView() <LineScrollViewDataSource>

@end

@implementation ChaptersView
{
    LineScrollView* lineScrollView;
}


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // chapter views
        lineScrollView = [[LineScrollView alloc] init];
        lineScrollView.dataSource = self;
        [self addSubview: lineScrollView];
    }
    return self;
}

#pragma mark - LineScrollViewDataSource Methods

-(void)lineScrollView:(LineScrollView *)lineScrollViewObj willShowIndex:(int)index
{
    LineScrollViewCell* cell = [lineScrollViewObj visibleCellAtIndex: index];
    
    
    // image
    int i = index % 4;
    NSString* imageName = [NSString stringWithFormat:@"%d", abs(i) + 1];
    UIImage* image = [UIImage imageNamed: imageName];
    
    
    // imageView
    int imageViewTag = 2008;
    UIImageView* imageView = (UIImageView*)[cell viewWithTag:imageViewTag];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame: cell.bounds];
        imageView.tag = imageViewTag;
        [cell addSubview: imageView];
    }
    imageView.image = image;
    
    
    // index label
    int indexLableTag = 2010;
    UILabel* indexLabel = (UILabel*)[cell viewWithTag: indexLableTag];
    if (!indexLabel) {
        indexLabel = [[UILabel alloc] initWithFrame: cell.bounds];
        indexLabel.tag = indexLableTag;
        [cell addSubview: indexLabel];
    }
    indexLabel.font = [UIFont fontWithName:@"Arial" size:CanvasFontSize(100)];
    indexLabel.text = [NSString stringWithFormat:@"%d", index];
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
    //    [indexLabel adjustsFontSizeToFitWidth];
}


-(void)lineScrollView:(LineScrollView *)lineScrollView didSelectIndex:(int)index
{
    ACTION.gameState.currentChapter = index;
    [ACTION.gameEvent gameStart];
}

@end
