#import "InAppIMNavgationController.h"
#import "AppInterface.h"

@interface InAppIMNavgationController () <UINavigationControllerDelegate>

@end

@implementation InAppIMNavgationController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeVariables];
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self initializeVariables];
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initializeVariables];
    }
    return self;
}


-(void) initializeVariables
{
    self.delegate = self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Class Methods

InAppIMNavgationController* sharedInstance = nil;

+(void)initialize
{
    if (self == [InAppIMNavgationController class]) {
        InAppIMRootController* inAppIMRootController = [[InAppIMRootController alloc] init];
        sharedInstance = [[InAppIMNavgationController alloc] initWithRootViewController: inAppIMRootController];
    }
}

+(InAppIMNavgationController*) sharedInstance
{
    return sharedInstance;
}

+(void) show
{
    InAppIMNavgationController* imNavController = [InAppIMNavgationController sharedInstance];
//    imNavController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    IAISimpleRoomInfo *roomInfo=[[IAISimpleRoomInfo alloc] init];
    [roomInfo setTitle:@"自定义聊天室-C"];
    [roomInfo setUniqueKey:@"cn.inappim.CustomRoom"];
    [InAppIMSDK enterCustomRoomClient:roomInfo navigationController: imNavController.topViewController animated:YES];
    
    [VIEW.controller presentViewController:imNavController animated:YES completion:nil];
}



#pragma mark - Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (navigationController.viewControllers.count == 1) {
//
//        [UIView animateWithDuration: 0.5 animations:^{
//            navigationController.view.backgroundColor = [UIColor clearColor];
//            viewController.view.backgroundColor = [UIColor clearColor];
//            
//            navigationController.view.superview.alpha = 0.0;
//            navigationController.view.alpha = 0.0;
//            viewController.view.alpha = 0.0;
//        } completion:^(BOOL finished) {
            [VIEW.controller dismissViewControllerAnimated: YES completion:nil];
//        }];
    }
    
}


@end
