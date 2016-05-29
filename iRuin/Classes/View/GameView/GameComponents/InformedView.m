#import "InformedView.h"
#import "AppInterface.h"


#pragma mark - InnerContenView

@interface InnerContenView : UIView

@property(strong) GradientLabel* label;

@end

@implementation InnerContenView

@synthesize label;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // default 
        label = [[GradientLabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 5;
        [self addSubview: label];
    }
    return self;
}

@end


#pragma mark - InformedView


@interface InformedView ()

@property(strong) UIView* contentView;

@end

@implementation InformedView

@synthesize contentView;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // self default
        self.clipsToBounds = YES;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0f;
        self.showDuration = 3.0f;
        
        // content view
        CGFloat width = CGRectGetWidth(frame);
        contentView = [[InnerContenView alloc] initWithFrame:CGRectMake(0, 0, width / 2, 1)];
        [contentView setCenterX: width / 2];
        contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:contentView];
    }
    return self;
}

+(void) show
{
    [self show:DATA.config[@"InformedView_Show"] dismiss:DATA.config[@"InformedView_Dismiss"]];
}

+(void) show:(NSDictionary*)showConfig dismiss:(NSDictionary*)dismissConfig
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    InformedView* informedView = [[InformedView alloc] initWithFrame:CGRectMake(-1, 0, CGRectGetWidth(window.frame) + 2, 1)];
    [window addSubview:informedView];
    
    [ACTION.gameEffect designateValuesActionsTo:informedView config:showConfig completion:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(informedView.showDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [ACTION.gameEffect designateValuesActionsTo:informedView config:dismissConfig completion:^{
                [informedView removeFromSuperview];
            }];
            
        });
        
    }];
}

@end
