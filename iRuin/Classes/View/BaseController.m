#import "BaseController.h"

@implementation BaseController


-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Hide status bar , for ios version <= ios 6.0
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    return self;
}


#pragma mark - Override Methods
// Hide status bar , for ios version >= ios 7
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
