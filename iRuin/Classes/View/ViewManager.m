#import "ViewManager.h"
#import "AppInterface.h"



@implementation ViewManager


@synthesize window;
@synthesize controller;



static ViewManager* sharedInstance = nil;

+(void)initialize {
    // http://blog.leichunfeng.com/blog/2015/05/02/objective-c-plus-load-vs-plus-initialize/
    // Because runtime use objc_msgSend to invoke initialize method 
    // Without that extra check, your initializations could run twice in this class, if you ever have a subclass that doesn't implement its own +initialize method.
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
        controller = [[GameController alloc] init];
        
        self.blackPoint = CGPointMake(-250, -250);
    }
    return self;
}

-(GameView*) gameView
{
    return controller.gameView;
}

-(ChaptersView*) chaptersView
{
    return controller.chaptersView;
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
    [_actionExecutorManager registerActionExecutor: effect_ValuesSet        executor:       [[NSClassFromString(@"ElementsExecutor") alloc] init]];
    [_actionExecutorManager registerActionExecutor: effect_Explode          executor:       [[NSClassFromString(@"ExplodesExecutor") alloc] init]];
    [_actionExecutorManager registerActionExecutor: effect_ANIMATION        executor:       [[NSClassFromString(@"ImageAnimator") alloc] init] ];
    [_actionExecutorManager registerActionExecutor: effect_AUDIO            executor:       [[NSClassFromString(@"AudiosExecutor") alloc] init] ];
    [_actionExecutorManager registerActionExecutor: effect_Font             executor:       [[NSClassFromString(@"TextFormatter") alloc] init] ];
    
    [_actionExecutorManager registerActionExecutor: effect_Invocation       executor:       [[NSClassFromString(@"InvocationExecutor") alloc] init] ];
    
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
