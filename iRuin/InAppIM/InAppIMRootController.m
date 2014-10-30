#import "InAppIMRootController.h"
#import "AppInterface.h"

@implementation InAppIMRootController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    [VIEW.controller dismissViewControllerAnimated: YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


@end
