#import "ViewManager.h"
#import "AppInterface.h"

@implementation ViewManager

@synthesize window;
@synthesize frame;
@synthesize controller;

@synthesize gameView;
@synthesize chaptersView;

static ViewManager* sharedInstance = nil;

+(void)initialize {
    // Without that extra check, your initializations could run twice in this class,
    // if you ever have a subclass that doesn't implement its own +initialize method.
    if (self == [ViewManager class]) {
        sharedInstance = [[ViewManager alloc] init];
    }
}

+(ViewManager*) getInstance {
    return sharedInstance;
}

#pragma mark - initialization

- (id)init
{
    self = [super init];
    if (self) {
        frame = [[FrameManager alloc] init];
        controller = [[GameController alloc] init];
        
        gameView = [[GameView alloc] init];
        chaptersView = [[ChaptersView alloc] init];
        
        for (int i = 0; i < 5; i++)  NSLog(@"%d", arc4random() % 10);
    }
    return self;
}

-(void) initializeWithData {
    [self setupActionExecutor];
}

-(void) setupActionExecutor {
    // set up action executor
    _actionExecutorManager = [[ActionExecutorManager alloc] init];
    
    // QUEUE
    [_actionExecutorManager registerActionExecutor: effect_ValuesAnimation  executor:       [[NSClassFromString(@"QueueExecutorBase") alloc] init]];
    [_actionExecutorManager registerActionExecutor: effect_Movement         executor:       [[NSClassFromString(@"PositionsExecutor") alloc] init]];
    
    // ELEMENT
    [_actionExecutorManager registerActionExecutor: effect_ValueSet         executor:       [[NSClassFromString(@"ElementExecutor") alloc] init]];
    [_actionExecutorManager registerActionExecutor: effect_Explode          executor:       [[NSClassFromString(@"ExplodesExecutor") alloc] init]];
    [_actionExecutorManager registerActionExecutor: effect_ANIMATION        executor:       [[NSClassFromString(@"ImageAnimator") alloc] init] ];
    [_actionExecutorManager registerActionExecutor: effect_AUDIO            executor:       [[NSClassFromString(@"AudioPlayer") alloc] init] ];
    [_actionExecutorManager registerActionExecutor: effect_Font             executor:       [[NSClassFromString(@"TextFormatter") alloc] init] ];
    
    _actionDurations = [[QueueTimeCalculator alloc] init];
    NSDictionary* actionExecutors = [_actionExecutorManager getActionExecutors];
    for (NSString* action in actionExecutors) {
        ActionExecutorBase* executor = actionExecutors[action];
        if ([executor isKindOfClass:[QueueExecutorBase class]]) {
            ((QueueExecutorBase*)executor).delegate = _actionDurations;
        }
    }
}

@end
