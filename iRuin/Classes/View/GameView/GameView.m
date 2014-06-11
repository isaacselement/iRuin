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
