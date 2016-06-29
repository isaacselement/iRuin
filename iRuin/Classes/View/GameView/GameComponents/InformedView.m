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
        self.userInteractionEnabled = NO;
        
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
        self.userInteractionEnabled = NO;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0f;
        
        // content view
        CGFloat width = CGRectGetWidth(frame);
        contentView = [[InnerContenView alloc] initWithFrame:CGRectMake(0, 0, width / 2, 1)];
        [contentView setCenterX: width / 2];
        contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:contentView];
    }
    return self;
}

@end
