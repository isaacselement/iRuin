#import "ActionManager.h"
#import "AppInterface.h"

@implementation ActionManager


static ActionManager* sharedInstance = nil;


@synthesize gameEvent;
@synthesize gameState;
@synthesize gameEffect;

@synthesize modesRepository;


+(void)initialize {
    if (self == [ActionManager class]) {
        sharedInstance = [[ActionManager alloc] init];
    }
}

+(ActionManager*) getInstance {
    return sharedInstance;
}


- (id)init
{
    self = [super init];
    if (self) {
        modesRepository = [[NSMutableDictionary alloc] init];
        
        gameEvent = [[GameEvent alloc] init];
        gameState = [[GameState alloc] init];
        gameEffect = [[GameEffect alloc] init];
    }
    return self;
}

-(void) launchAppProcedures
{
    
    [DATA initializeWithData];
    [VIEW initializeWithData];
    [self initializeGameModes];
    
    [self renderFramesWithCurrentOrientation];
    
    [gameEvent gameLaunch];
}

-(void) initializeGameModes
{
    NSArray* modes = [ConfigHelper getSupportedModes];
    NSString* eventStr = kEVENT;
    NSString* stateStr = kSTATE;
    NSString* effectStr = kEFFECT;
    for (int i = 0; i < modes.count; i++) {
        NSString* mode = modes[i];
        
        // event
        NSString* eventClass = [NSString stringWithFormat: @"%@%@", mode, eventStr];
        BaseEvent* event = [[NSClassFromString(eventClass) alloc] init];
        // state
        NSString* stateClass = [NSString stringWithFormat: @"%@%@", mode, stateStr];
        BaseState* state = [[NSClassFromString(stateClass) alloc] init];
        // effect
        NSString* effectClass = [NSString stringWithFormat:@"%@%@", mode, effectStr];
        BaseEffect* effect = [[NSClassFromString(effectClass) alloc] init];
        
        // assign the pointer
        event.state = state;
        state.effect = effect;
        effect.event = event;
        
        // add to repository , maintain the retain count
        [modesRepository setObject: @{eventStr:event, stateStr:state, effectStr:effect} forKey:mode];
    }
}

-(void) switchToMode: (NSString*)mode chapter:(int)chapter
{
    // destroy initialize
    [self.modeEvent eventUnInitialize];
    [self.modeState stateUnInitialize];
    [self.modeEffect effectUnInitialize];
    
    // change the config
    [DATA setConfigByMode:mode chapter:chapter];
    
    self.modeEvent   = [[modesRepository objectForKey: mode] objectForKey: kEVENT];
    self.modeState   = [[modesRepository objectForKey: mode] objectForKey: kSTATE];
    self.modeEffect  = [[modesRepository objectForKey: mode] objectForKey: kEFFECT];
    
    // initialize
    [self.modeEvent eventInitialize];
    [self.modeState stateInitialize];
    [self.modeEffect effectInitialize];
}


#pragma mark -

-(void) renderFramesWithCurrentOrientation
{
    // first, set up design/canvas size
    [FrameTranslater setCanvas: [RectHelper parseSize:DATA.config[@"DESIGN"]]];
    
    [ACTION.gameEffect designateToControllerWithConfig:DATA.config[@"GAME_ENTER"]];
    [self createOrUpdateSymbolsWithFramesMatrix];
}


-(void) createOrUpdateSymbolsWithFramesMatrix
{
    ContainerView* containerView = VIEW.gameView.containerView;
    CGRect visualArea = containerView.bounds;
    CGRect visualFrame = containerView.frame;
    
    // set up the basic views and positions array
    NSArray* matrixs = DATA.config[@"MATRIX"];
    [QueuePositionsHelper setRectsRepository: matrixs];
    
    
    // A. will update or create views in QueueViewsHelper.viewsRepository
    [QueueViewsHelper setViewsRepository: matrixs viewClass:[SymbolView class]];
    
    // B. will update views in QueueViewsHelper.viewsInVisualArea , we need the structures
    [QueueViewsHelper setViewsInVisualArea: visualArea];
    
    
    BOOL isVisualAreaClipsToBounds = [DATA.config[@"IsVisualAreaClipsToBounds"] boolValue];
//#ifndef DEBUG    // Comment it for test , in production , open it .
    containerView.clipsToBounds = isVisualAreaClipsToBounds;
//#endif
    if (! isVisualAreaClipsToBounds) {
        [QueuePositionsHelper refreshRectsPositionsRepositoryWhenClipsToBoundsIsNO:visualFrame];
    }
    
    
    // A
    [IterateHelper iterateTwoDimensionArray:QueueViewsHelper.viewsRepository handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
        SymbolView* symbolView = (SymbolView*)obj;
        // the new symbols
        if (!symbolView.superview) {
            // cause it's new , so should restore
            [symbolView restore];
            [VIEW.gameView.containerView addSubview: symbolView];
            [symbolView setSize:[QueuePositionsHelper.rectsRepository[outterIndex][innerIndex] CGRectValue].size];
            [symbolView setValidArea: symbolView.bounds];
            symbolView.identification = [SymbolView getOneRandomSymbolIdentification];
        }
        return NO;
    }];
    
}


@end
