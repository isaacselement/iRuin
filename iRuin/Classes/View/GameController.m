#import "GameController.h"
#import "AppInterface.h"

#import "GameScrollView.h"
#import "SharedMotionManager.h"


@implementation GameController

@synthesize gameView;
@synthesize chaptersView;


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName: nil bundle:nibBundleOrNil];
    if (self) {
        chaptersView = [[ChaptersView alloc] init];
        gameView = [[GameView alloc] init];
    }
    return self;
}

#pragma mark - Override Methods

-(void)viewDidLoad {
    [super viewDidLoad];
    // Give a new uiview , cause the origin is a strange mess thing
    self.view = [[GameScrollView alloc] initWithFrame:self.view.bounds];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview: chaptersView];
    [self.view addSubview: gameView];
    
    
    // monitore the battery
    // if it work , upvote this: http://stackoverflow.com/a/14834620/1749293
    [self performSelector:@selector(startGyroParallex) withObject:nil afterDelay: 1];
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStatus) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStatus) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
}

-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

// <= ios 7
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector:@selector(reRenderWithDeviceOrientation) object:nil];
    [self performSelector: @selector(reRenderWithDeviceOrientation) withObject:nil afterDelay: 0.5];
}

// >= ios 8
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector:@selector(reRenderWithDeviceOrientation) object:nil];
    [self performSelector: @selector(reRenderWithDeviceOrientation) withObject:nil afterDelay: 0.5];
}


-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [(AudiosExecutor*)[VIEW.actionExecutorManager getActionExecutor: effect_AUDIO] clearCaches];
}






#pragma mark - 

- (void)startGyroParallex
{
    SharedMotionManager* motionManager = [SharedMotionManager sharedInstance];
    if (motionManager.deviceMotionAvailable) {  // same as motionManager.gyroAvailable, cause accelerometer always have , see the doc
        motionManager.gyroUpdateInterval = 1/20;
        [motionManager startGyroUpdatesToQueue: [SharedOperationQueue sharedInstance] withHandler:^(CMGyroData *gyroData, NSError *error) {
            CMRotationRate rotationRate = gyroData.rotationRate;
            
            DLog(@"%f, %f, %f", rotationRate.x, rotationRate.y, rotationRate.z);
        }];
    }
}

- (void)batteryStatus
{    
    if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnknown) {

    } else {
        float batteryLevel = [[UIDevice currentDevice] batteryLevel];
        DLog(@"batteryLevel: %f", batteryLevel);
        if (batteryLevel < 0.1) {
            [[SharedMotionManager sharedInstance] stopGyroUpdates];
        } else {
            [self startGyroParallex];
        }
    }
}


#pragma mark - Orientation Change

-(void) reRenderWithDeviceOrientation
{
    [ACTION renderFramesWithCurrentOrientation];
    
    return;
    // Temp -------------------------------
    if (! ACTION.gameState.isGameStarted) {
        
        // Temporary code here.
        [UIView animateWithDuration: 0.5 animations:^{
            [IterateHelper iterateTwoDimensionArray:QueueViewsHelper.viewsRepository handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
                SymbolView* symbolView = (SymbolView*)obj;
                CGRect rect = [QueuePositionsHelper.rectsRepository[outterIndex][innerIndex] CGRectValue];
                symbolView.frame = rect;
                return NO;
            }];
        }];
    }
}

@end
