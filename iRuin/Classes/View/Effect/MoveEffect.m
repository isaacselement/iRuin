#import "MoveEffect.h"
#import "AppInterface.h"

@implementation MoveEffect
{
    PPSSignatureView* routeView;
}


#pragma mark - Override Methods

-(void)effectInitialize
{
    [super effectInitialize];
    
    if (!routeView) {
        routeView = [[PPSSignatureView alloc] init];
        routeView.backgroundColor = [UIColor clearColor];
    }
    
    [VIEW.gameView addSubview: routeView];
    [routeView erase];
    routeView.frame = VIEW.gameView.containerView.frame;
}

-(void)effectUnInitialize
{
    [super effectUnInitialize];
    
    [routeView removeFromSuperview];
}

-(void)effectTouchesBegan:(SymbolView *)symbol location:(CGPoint)location
{
    [super effectTouchesBegan:symbol location:location];
    
    [routeView erase];
}

-(void)effectStartRollIn
{
    [super effectStartRollIn];
    
    [routeView erase];
}

-(void)effectStartRollOut
{
    [super effectStartRollOut];
    
    [routeView erase];
}


@end
