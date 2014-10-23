#import "AppDelegate.h"
#import "AppInterface.h"

@implementation AppDelegate

#ifdef DEBUG
void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"Crash : %@", exception);
    NSLog(@"Stack Trace : %@", [exception callStackSymbols]);
}
#endif


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUG
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#endif
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = VIEW.controller;
    VIEW.window = self.window;
    
    [ACTION launchAppProcedures];
    
    [self.window makeKeyAndVisible];
    
    // InAppIM
    [self initInAppIMSDK:application didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    [InAppIMSDK applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [InAppIMSDK applicationDidEnterBackground:application];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [InAppIMSDK handleRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [InAppIMSDK handleFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    [InAppIMSDK application:application didReceiveRemoteNotification:userInfo navigationController:navController];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([AllSDKManager getCurrentSDKType] == AllSDKType_IAIIM) {
        return [InAppIMSDK handleOpenURL:url delegate:self];
    }
    return YES;
}





#pragma mark - InAppIM

-(void)initInAppIMSDK:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [InAppIMSDK application:application didFinishLaunchingWithOptions:launchOptions];
    [InAppIMSDK registerApp: @"543f77915fe8bd75b0436c42"];
    [InAppIMSDK enableDebugMode:NO];
     [InAppIMSDK enableAccessLocation:NO];
    
    {
        //sina
        [InAppIMSDK connectPlatformWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"947521933",KHCAppKey,@"https://api.weibo.com/oauth2/default.html",KHCRedirectUri,IAI_SNS_SinaWeibo,KIAI_SNS_PlatformId, nil]];
        
        //baidu
        [InAppIMSDK connectPlatformWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Idhix6Yl5s0aSNocBzGzhX2A",KHCAppKey,@"3117382",KHCAppId,IAI_SNS_Baidu,KIAI_SNS_PlatformId, nil]];
        
        //qq
        [InAppIMSDK connectPlatformWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"1101775317",KHCAppId,IAI_SNS_QQ,KIAI_SNS_PlatformId, nil]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InAppIMWillAuth:) name:KIAI_InAppIMSDK_Will_AuthNtf object:nil];
    
    [InAppIMSDK init];
    
    
    //用户切换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userWillSwitch:) name:KIAIUserWillSwitchNtf object:nil];
}

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



@end
