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
        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(deviceOrientationDidChangedWithNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
    }
    return self;
}

#pragma mark - Override Methods

-(void)viewDidLoad {
    [super viewDidLoad];
    // Give a new uiview , cause the origin is a strange mess thing
    self.view = [[GameBaseView alloc] initWithFrame:self.view.bounds];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void) deviceOrientationDidChangedWithNotification: (NSNotification*)notification
{
    DLog(@"deviceOrientationDidChangedWithNotification: %d . %f X %f", [UIDevice currentDevice].orientation, self.view.bounds.size.width, self.view.bounds.size.height);
    
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector:@selector(reRenderWithDeviceOrientation) object:nil];
    [self performSelector: @selector(reRenderWithDeviceOrientation) withObject:nil afterDelay: 0.5];
}


#pragma mark - Public Methods

-(void) switchToView: (UIView*)view {
    [self.view addSubview: view];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.type = kCATransitionFade;
    [[self.view layer] addAnimation:transition forKey: nil];
}

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
