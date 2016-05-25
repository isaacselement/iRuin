#import "InformedView.h"
#import "UIView+Frame.h"
#import "CALayer+Frame.h"

@interface InformedView ()

@property UIView* contentView;

@end

@implementation InformedView

@synthesize contentView;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIApplication sharedApplication].keyWindow.frame) / 2, 1)];
        contentView.center = [self middlePoint];
        contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:contentView];
        
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0f;
    }
    return self;
}

+(void) show
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    InformedView* informedView = [[InformedView alloc] initWithFrame:CGRectMake(-1, 0, CGRectGetWidth(window.frame) + 2, 1)];
    [window addSubview:informedView];
    informedView.center = [window middlePoint];
    
    [UIView animateWithDuration:0.5 animations:^{
        [informedView setSizeHeight:100];
        informedView.center = [window middlePoint];
        [informedView.contentView setSizeHeight:100];
        informedView.contentView.center = [informedView middlePoint];
        
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.5 animations:^{
                [informedView setSizeHeight: 1];
                informedView.center = [window middlePoint];
            } completion:^(BOOL finished) {
                [informedView removeFromSuperview];
            }];
        });
    }];
}

@end
