#import "InAppIMRootController.h"
#import "AppInterface.h"

@implementation InAppIMRootController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


@end
