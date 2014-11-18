#import "InAppIMRootController.h"
#import "AppInterface.h"

@implementation InAppIMRootController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: VIEW.window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.dimBackground = YES;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay: 2.0];
    
    if (self.isComeFromOutside) {
        self.isComeFromOutside = !self.isComeFromOutside;
        
        hud.detailsLabelText = @"Twitter & Facebook are on the way :) ";
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [InAppIMSDK enterCustomRoomClient: self.simpleRoomInfo navigationController: self animated:YES];
            
            [[ScheduledTask sharedInstance] pause];
        });
        
    } else {
        hud.detailsLabelText = @"Do u have a good chat ? :-P ";
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [VIEW.controller dismissViewControllerAnimated: YES completion:nil];

            [[ScheduledTask sharedInstance] start];
        });
    }
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}



@end
