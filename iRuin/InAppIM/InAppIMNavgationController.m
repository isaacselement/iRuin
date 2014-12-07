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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initializeVariables
{
    self.delegate = self;
}


#pragma mark - Class Methods

InAppIMNavgationController* inAppControllerSharedInstance = nil;

+(void)initialize
{
    if (self == [InAppIMNavgationController class]) {
        InAppIMRootController* inAppIMRootController = [[InAppIMRootController alloc] init];
        inAppControllerSharedInstance = [[InAppIMNavgationController alloc] initWithRootViewController: inAppIMRootController];
    }
}

+(InAppIMNavgationController*) sharedInstance
{
    return inAppControllerSharedInstance;
}


#pragma mark - Public Methods

-(void) showWithTilte:(NSString*)title uniqueKey:(NSString*)uniqueKey
{
    IAISimpleRoomInfo *roomInfo=[[IAISimpleRoomInfo alloc] init];
    [roomInfo setTitle: title];
    [roomInfo setUniqueKey: uniqueKey];
    
    
    InAppIMNavgationController* imNavController = [InAppIMNavgationController sharedInstance];
    imNavController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    InAppIMRootController* imRootController = [imNavController.viewControllers firstObject];
    imRootController.simpleRoomInfo = roomInfo;
    imRootController.isComeFromOutside = YES;
    
    
    [VIEW.controller presentViewController:imNavController animated:YES completion:nil];
}

-(void)initInAppIMSDK:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary* appKeys = DATA.config[@"SNS"];
    
    [InAppIMSDK application:application didFinishLaunchingWithOptions:launchOptions];
    [InAppIMSDK registerApp: appKeys[@"InAppIMAppKey"]];
    [InAppIMSDK enableDebugMode:NO];
    [InAppIMSDK enableAccessLocation:NO];
    
    //sina
    [InAppIMSDK connectPlatformWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:appKeys[@"WeiboAppKey"],KHCAppKey,appKeys[@"WeiboCallBackURL"],KHCRedirectUri,IAI_SNS_SinaWeibo,KIAI_SNS_PlatformId, nil]];
    
    //baidu
    [InAppIMSDK connectPlatformWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:appKeys[@"BaiduAPIKey"],KHCAppKey,appKeys[@"BaiduAppID"],KHCAppId,IAI_SNS_Baidu,KIAI_SNS_PlatformId, nil]];
    
    //qq
    [InAppIMSDK connectPlatformWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:appKeys[@"QQAppID"],KHCAppId,IAI_SNS_QQ,KIAI_SNS_PlatformId, nil]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InAppIMWillAuth:) name:KIAI_InAppIMSDK_Will_AuthNtf object:nil];
    
    [InAppIMSDK init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userWillSwitch:) name:KIAIUserWillSwitchNtf object:nil];
}


-(void) applicationWillEnterForeground:(UIApplication*)application
{
    [InAppIMSDK applicationWillEnterForeground:application];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
    [InAppIMSDK applicationDidEnterBackground:application];
}

-(void) handleRegisterForRemoteNotificationsWithDeviceToken: (NSData *)deviceToken
{
    [InAppIMSDK handleRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

-(void) handleFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [InAppIMSDK handleFailToRegisterForRemoteNotificationsWithError:error];
}

-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [InAppIMSDK application:application didReceiveRemoteNotification:userInfo navigationController:[InAppIMNavgationController sharedInstance]];
}

-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotatioe
{
    if ([AllSDKManager getCurrentSDKType] == AllSDKType_IAIIM) {
        return [InAppIMSDK handleOpenURL:url delegate:self];
    }
    return YES;
}

#pragma mark - 

-(void)InAppIMWillAuth:(NSNotification*)notification
{
    [AllSDKManager setCurrentSDKType:AllSDKType_IAIIM];
}

-(void)userWillSwitch:(NSNotification*)notification
{
    UIViewController *vc=nil;
    if (notification.object  && [(NSDictionary*)notification.object objectForKey:KViewControllerBeforeEnterInAppIM]) {
        vc=[(NSDictionary*)notification.object objectForKey:KViewControllerBeforeEnterInAppIM];
    }
    
    //如果没有用户体系，直接使用InAppIM Sns授权界面
    if(vc && vc==VIEW.controller){
        [InAppIMSDK authWithIAIAuthView:^(BOOL sucess, NSDictionary *userInfo, NSError *error) {
            
        } navigationController:VIEW.controller animated:YES backAfterAuthed:NO];
    }
}


#pragma mark - Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}


@end
