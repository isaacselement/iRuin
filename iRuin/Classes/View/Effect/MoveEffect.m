#import "MoveEffect.h"
#import "AppInterface.h"

@implementation MoveEffect
{
    PPSSignatureView* trackView;
}


#pragma mark - Override Methods

-(void)effectInitialize
{
    [super effectInitialize];
    
    if (!trackView) {
        trackView = [[PPSSignatureView alloc] init];
        trackView.backgroundColor = [UIColor clearColor];
    }
    
    [VIEW.gameView addSubview: trackView];
    [trackView erase];
    trackView.frame = VIEW.gameView.containerView.frame;
}

-(void)effectUnInitialize
{
    [super effectUnInitialize];
    
    [trackView removeFromSuperview];
}

-(void)effectTouchesBegan:(SymbolView *)symbol location:(CGPoint)location
{
    [super effectTouchesBegan:symbol location:location];
    
    [trackView erase];
}

-(void)effectTouchesEnded:(SymbolView *)symbol location:(CGPoint)location
{
    [super effectTouchesEnded:symbol location:location];
    
    [trackView erase];
}

-(void)effectTouchesCancelled:(SymbolView *)symbol location:(CGPoint)location
{
    [super effectTouchesCancelled:symbol location:location];
    
    [trackView erase];
}

-(void)effectStartRollIn
{
    [super effectStartRollIn];
    
    [trackView erase];
}

-(void)effectStartRollOut
{
    [super effectStartRollOut];
    
    [trackView erase];
}


@end
