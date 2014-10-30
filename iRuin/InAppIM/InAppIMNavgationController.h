#import <UIKit/UIKit.h>

@interface InAppIMNavgationController : UINavigationController



#pragma mark - Class Methods 


+(InAppIMNavgationController*) sharedInstance;


#pragma mark - Public Methods

-(void) showWithTilte:(NSString*)title uniqueKey:(NSString*)uniqueKey;

-(void) initInAppIMSDK:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;


-(void) applicationWillEnterForeground:(UIApplication*)application;

-(void) applicationDidEnterBackground:(UIApplication*)application;

-(void) handleRegisterForRemoteNotificationsWithDeviceToken: (NSData *)deviceToken;

-(void) handleFailToRegisterForRemoteNotificationsWithError:(NSError*)error;

-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotatioe;


@end
