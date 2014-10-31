#import "GameController.h"
#import "AppInterface.h"

@implementation GameController

@synthesize gameView;
@synthesize chaptersView;


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName: nil bundle:nibBundleOrNil];
    if (self) {
        chaptersView = [[ChaptersView alloc] init];
        gameView = [[GameView alloc] init];
        
        // Add the UIDeviceOrientationDidChangeNotification
//        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(deviceOrientationDidChangedWithNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
    }
    return self;
}

#pragma mark - Override Methods

-(void)viewDidLoad {
    [super viewDidLoad];
    // Give a new uiview , cause the origin is a strange mess thing
    self.view = [[GameBaseView alloc] initWithFrame:self.view.bounds];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview: chaptersView];
    [self.view addSubview: gameView];
}

// <= ios 7
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    [NSObject cancelPreviousPerformRequestsWithTarget: self selector:@selector(reRenderWithDeviceOrientation) object:nil];
//    [self performSelector: @selector(reRenderWithDeviceOrientation) withObject:nil afterDelay: 0.5];
    
        [self reRenderWithDeviceOrientation];
}

// >= ios 8
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
//    [NSObject cancelPreviousPerformRequestsWithTarget: self selector:@selector(reRenderWithDeviceOrientation) object:nil];
//    [self performSelector: @selector(reRenderWithDeviceOrientation) withObject:nil afterDelay: 0.5];
    
    [self reRenderWithDeviceOrientation];
}

//-(void) deviceOrientationDidChangedWithNotification: (NSNotification*)notification
//{
//    [NSObject cancelPreviousPerformRequestsWithTarget: self selector:@selector(reRenderWithDeviceOrientation) object:nil];
//    [self performSelector: @selector(reRenderWithDeviceOrientation) withObject:nil afterDelay: 0.5];
//}

#pragma mark - Orientation Change

-(void) reRenderWithDeviceOrientation
{
    [ACTION renderFramesWithCurrentOrientation];
    
    [self deviceOrientationChangedRefreshSymbolsFramesWhileGameIsStarted];
}


-(void) deviceOrientationChangedRefreshSymbolsFramesWhileGameIsStarted
{
    if (! ACTION.gameState.isGameStarted) return;
        
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

@end
