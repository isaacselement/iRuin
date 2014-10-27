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
        
        
        // Hide status bar , for ios version <= ios 6.0
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        // Add the UIDeviceOrientationDidChangeNotification
        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(deviceOrientationDidChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
    }
    return self;
}

#pragma mark - Override Methods
// Hide status bar , for ios version >= ios 7
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    // Give a new uiview , cause the origin is a strange mess thing
    self.view = [[GameBaseView alloc] initWithFrame:self.view.bounds];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void) deviceOrientationDidChanged: (NSNotification*)notification
{
    DLog(@"deviceOrientationDidChanged: %d . %f X %f", [UIDevice currentDevice].orientation, self.view.bounds.size.width, self.view.bounds.size.height);
    
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector:@selector(renderWithCurrentOrientation) object:nil];
    [self performSelector: @selector(renderWithCurrentOrientation) withObject:nil afterDelay: 0.5];
}


#pragma mark - Public Methods

-(void) switchToView: (UIView*)view {
    [self.view addSubview: view];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.type = kCATransitionReveal;
    [[self.view layer] addAnimation:transition forKey: nil];
}

#pragma mark - Orientation Change

-(void) renderWithCurrentOrientation
{
    [ACTION renderFramesWithCurrentOrientation];
    
    NSArray* viewsRepository = QueueViewsHelper.viewsRepository;
    NSArray* rectsRepository = QueuePositionsHelper.rectsRepository;
    
//    return;
    
    // symbols frames
    if (! ACTION.gameState.isGameStarted) {
        [ACTION.currentEffect effectStartRollIn];

        [IterateHelper iterateTwoDimensionArray:viewsRepository handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
            SymbolView* symbolView = (SymbolView*)obj;
            symbolView.frame = [rectsRepository[outterIndex][innerIndex] CGRectValue];
            return NO;
        }];
        
    } else {

        // Temporary code here.
        [UIView animateWithDuration: 0.5 animations:^{
            [IterateHelper iterateTwoDimensionArray:viewsRepository handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
                SymbolView* symbolView = (SymbolView*)obj;
                symbolView.frame = [rectsRepository[outterIndex][innerIndex] CGRectValue];
                return NO;
            }];
        }];
    }
}

@end
