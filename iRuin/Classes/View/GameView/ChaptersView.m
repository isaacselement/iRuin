#import "ChaptersView.h"
#import "AppInterface.h"


@interface INAppImNavgationController : UINavigationController <UINavigationControllerDelegate>

@end

@implementation INAppImNavgationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (navigationController.viewControllers.count == 1) {

        [UIView animateWithDuration: 0.5 animations:^{
            navigationController.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [VIEW.controller dismissViewControllerAnimated: NO completion:nil];
        }];
    }
}

@end




@interface ChaptersView() <LineScrollViewDataSource>

@end

@implementation ChaptersView
{
    
    LineScrollView* lineScrollView;
    
    UIView* testView;
}


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // chapter views
        lineScrollView = [[LineScrollView alloc] init];
        lineScrollView.dataSource = self;
        [self addSubview: lineScrollView];
        
        
        
        // for test now
        NormalButton* button = [NormalButton buttonWithType:UIButtonTypeContactAdd];
        button.didClikcButtonAction = ^void(NormalButton* button){
            
            UIViewController* imController = [[UIViewController alloc] init];
            UINavigationController* imNavController = [[INAppImNavgationController alloc] initWithRootViewController:imController];
            imNavController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            IAISimpleRoomInfo *roomInfo=[[IAISimpleRoomInfo alloc] init];
            [roomInfo setTitle:@"自定义聊天室-C"];
            [roomInfo setUniqueKey:@"cn.inappim.CustomRoom"];
            [InAppIMSDK enterCustomRoomClient:roomInfo navigationController:imController animated:YES];
            
            [VIEW.controller presentViewController:imNavController animated:YES completion:nil];

        };
        
//        [self addSubview:button];
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
    [ACTION.currentEffect effectStartRollIn];
    [VIEW.controller switchToView: VIEW.gameView];
}

@end
