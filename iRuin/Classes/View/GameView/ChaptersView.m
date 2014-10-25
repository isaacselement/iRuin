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


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // background image view
        UIImageView* backgroundView = [[UIImageView alloc] init];
        backgroundView.image = [UIImage imageNamed:@"background"];
        [self addSubview: backgroundView];
        
        
        // chapter views
        LineScrollView* lineScrollView = [[LineScrollView alloc] init];
        lineScrollView.clipsToBounds = YES;
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
        
        [self addSubview:button];
    }
    return self;
}

#pragma mark - LineScrollViewDataSource Methods

-(void)lineScrollView:(LineScrollView *)lineScrollView willShowIndex:(int)index
{
    LineScrollViewCell* cell = [lineScrollView visibleCellAtIndex: index];
    
    
    // image
    int i = index % 4;
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
