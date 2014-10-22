#import "ChaptersView.h"
#import "AppInterface.h"


@interface ChaptersView() <LineScrollViewDataSource>

@end

@implementation ChaptersView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        LineScrollView* lineScrollView = [[LineScrollView alloc] init];
        lineScrollView.clipsToBounds = YES;
        lineScrollView.dataSource = self;
        [self addSubview: lineScrollView];
        
        
        // for test now
        NormalButton* button = [NormalButton buttonWithType:UIButtonTypeContactAdd];
        button.didClikcButtonAction = ^void(NormalButton* button){
            IAISimpleRoomInfo *roomInfo=[[IAISimpleRoomInfo alloc] init];
            [roomInfo setTitle:@"自定义聊天室-C"];
            [roomInfo setUniqueKey:@"cn.inappim.CustomRoom"];
            [InAppIMSDK enterCustomRoomClient:roomInfo navigationController:VIEW.controller animated:YES];
        };
        
        [self addSubview:button];
    }
    return self;
}

#pragma mark - LineScrollViewDataSource Methods

- (LineScrollViewCell *)lineScrollView:(LineScrollView *)lineScrollView cellAtIndex:(int)index
{
    LineScrollViewCell* cell = [[LineScrollViewCell alloc] init];
    return cell;
}

-(void)lineScrollView:(LineScrollView *)lineScrollView willShowIndex:(int)index
{
    LineScrollViewCell* cell = [lineScrollView visibleCellAtIndex: index];
    
    
    // image
    int i = index % 5;
    i = i + 1;
    UIImage* image = [UIImage imageNamed: [NSString stringWithFormat:@"%d", abs(i)]];
    
    
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
    [VIEW.controller switchToView: VIEW.gameView];
}

@end
