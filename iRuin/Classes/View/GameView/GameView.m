#import "GameView.h"
#import "AppInterface.h"

@implementation GameView
{
    NSMutableArray* _symbolsInContianer;
}

@synthesize headerView;
@synthesize containerView;

- (id)init
{
    self = [super init];
    if (self) {
        // view
        containerView = [[ContainerView alloc] init];
        headerView = [[HeaderView alloc] init];
        [self addSubview: containerView];
        [self addSubview: headerView];
        
        
        
        NormalButton* normalButton = [NormalButton buttonWithType:UIButtonTypeContactAdd];
        normalButton.didClikcButtonAction = ^void(NormalButton* btn) {
//            [VIEW.controller switchToView: VIEW.chaptersView];
            [ACTION.currentEffect effectStartRollOut];
        };
        normalButton.frame = CGRectMake(0, 0, 25, 25);
        [self addSubview: normalButton];
    }
    return self;
}


-(NSMutableArray*) symbolsInContainer
{
    if (!_symbolsInContianer) {
        _symbolsInContianer = [QueueViewsHelper viewsInVisualArea];
    }
    return _symbolsInContianer;
}


@end
