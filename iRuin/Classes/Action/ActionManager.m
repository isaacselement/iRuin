#import "ActionManager.h"
#import "AppInterface.h"

@implementation ActionManager


static ActionManager* sharedInstance = nil;


@synthesize gameEvent;
@synthesize gameState;

@synthesize gameModes;
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
        gameModes = @[MODE_MOVE, MODE_TOUCH, MODE_EXPLODE, MODE_DOTS, MODE_PULL, MODE_SWIPE];
        modesRepository = [[NSMutableDictionary alloc] init];
        
        gameEvent = [[GameEvent alloc] init];
        gameState = [[GameState alloc] init];
        
    }
    return self;
}

-(void) launchAppProcedures {
    [DATA initializeWithData];
    [VIEW initializeWithData];
    
    // modes
    [self establishGameModes];
    [self switchToMode: MODE_EXPLODE];
    
    // when chapter config is ready
    [gameState initializePrototypes];
    
    [self renderFramesWithCurrentOrientation];
    
//    [VIEW.controller switchToView: VIEW.gameView];
    
    NSDictionary* kkkl = [KeyValueCodingHelper getClassPropertieTypes:[CALayer class]];
    
    const char* lldfsaklfkdsal = @encode(CALayer);
    const char* lllll = @encode(float);
    const char* llllll = @encode(id);
    
    [VIEW.controller switchToView: VIEW.chaptersView];
}

-(void) establishGameModes
{
    NSArray* modes = gameModes;
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

-(void) switchToMode: (NSString*)mode
{
    _currentMode = mode;
    
    [DATA setConfigByMode: mode];
    
    self.currentEvent   = [[modesRepository objectForKey: mode] objectForKey: kEVENT];
    self.currentState   = [[modesRepository objectForKey: mode] objectForKey: kSTATE];
    self.currentEffect  = [[modesRepository objectForKey: mode] objectForKey: kEFFECT];
    
    // do some stuff
    [self.currentEvent eventInitialize];
    [self.currentState stateInitialize];
    [self.currentEffect effectInitialize];
}


#pragma mark -

-(void) renderFramesWithCurrentOrientation
{
    [self switchFrameDesignAndComponentsFrames];
    [self createOrUpdateSymbolsWithFramesMatrix];
    [self initializeNewSymbolsPrototypesAppearance];
}

-(void) switchFrameDesignAndComponentsFrames
{
    // set up design/canvas size
    [FrameTranslater setCanvasSize: [RectHelper parseSize:DATA.visualJSON[@"DESIGN"]]];
    
    // set up the game view and its subviews frames
    GameView* gameView = VIEW.gameView;
    gameView.frame = [RectHelper getScreenRectByControllerOrientation];
    [FrameHelper setSubViewsFrames: gameView config:DATA.visualJSON[@"GameView"]];
    
    
    // set up the chapters view and its subviews frames
    ChaptersView* chaptersView = VIEW.chaptersView;
    chaptersView.frame = [RectHelper getScreenRectByControllerOrientation];
    [FrameHelper setSubViewsFrames: chaptersView config:DATA.visualJSON[@"ChaptersView"]];
}

-(void) createOrUpdateSymbolsWithFramesMatrix
{
    ContainerView* containerView = VIEW.gameView.containerView;
    CGRect visualArea = containerView.bounds;
    CGRect visualFrame = containerView.frame;
    
    // set up the basic views and positions array
    NSArray* matrixs = DATA.visualJSON[@"MATRIX"];
    [QueuePositionsHelper setRectsRepository: matrixs];
    [QueueViewsHelper setViewsRepository: matrixs viewClass:[SymbolView class]];
    [QueueViewsHelper setViewsInVisualArea: visualArea];
    
    [IterateHelper iterateTwoDimensionArray: QueueViewsHelper.viewsInVisualArea handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
        SymbolView* symbolView = (SymbolView*)obj;
        symbolView.row = (int)outterIndex;
        symbolView.column = (int)innerIndex;
        return NO;
    }];
    
    BOOL isContainerClipsToBounds = [DATA.config[@"ContainerClipsToBounds"] boolValue];
    containerView.clipsToBounds = isContainerClipsToBounds;   // Comment it for test , in production , open it .
    if (! isContainerClipsToBounds) {
        [QueuePositionsHelper refreshRectsPositionsRepositoryWhenClipsToBoundsIsNO:visualFrame];
    }
}

-(void) initializeNewSymbolsPrototypesAppearance
{
    // set up all symbols attributes
    UIView* containerView = VIEW.gameView.containerView;
    NSArray* viewRepository = QueueViewsHelper.viewsRepository;
    NSArray* rectsRepository = QueuePositionsHelper.rectsRepository;
    [IterateHelper iterateTwoDimensionArray:viewRepository handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
        SymbolView* symbolView = (SymbolView*)obj;
        if (!symbolView.superview) {
            [containerView addSubview: symbolView];
            
            CGRect rect = [[[rectsRepository objectAtIndex: outterIndex] objectAtIndex: innerIndex] CGRectValue];
            [symbolView setSize: rect.size];                // we set the frame after the orientation has been stable
            [symbolView setValidArea: symbolView.bounds];
            
            [symbolView restore];
            
            Symbol* prototype = [ACTION.gameState oneRandomPrototype];
            symbolView.prototype = prototype;
            
            [ColorHelper setBorder: symbolView color:[UIColor flatBlackColor]];
        }
        return NO;
    }];
}


@end
