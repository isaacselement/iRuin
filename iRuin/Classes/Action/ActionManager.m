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
    [self renderFramesWithCurrentOrientation];
    
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
    [self switchFrameDesignChaptersViewGameViewFrames];
    [self createOrUpdateSymbolsWithFramesMatrix];
    [self initializeNewToContainerSymbolsPrototypesAppearance];
}

-(void) switchFrameDesignChaptersViewGameViewFrames
{
    // first, set up design/canvas size
    [FrameTranslater setCanvasSize: [RectHelper parseSize:DATA.visualJSON[@"DESIGN"]]];
    
    GameView* gameView = VIEW.gameView;
    gameView.frame = [RectHelper getScreenRectByControllerOrientation];
    
    ChaptersView* chaptersView = VIEW.chaptersView;
    chaptersView.frame = [RectHelper getScreenRectByControllerOrientation];
    
    // set handler
    [KeyValueCodingHelper setTranslateValueHandler:^id(id value, const char *type, NSString *key) {
        id result = value;
        if (strcmp(type, @encode(CGFloat)) == 0) {
            if ([key rangeOfString:@"Width"].location != NSNotFound) {
                CGFloat num = [value floatValue];
                result = @(CanvasW(num));
            }
        }
        return result;
    }];
    [FrameHelper setValues:VIEW.controller config:DATA.visualJSON[@"GameController"]];
    
    // remove handler
    [KeyValueCodingHelper setTranslateValueHandler:nil];
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
    
    
    BOOL isContainerClipsToBounds = [DATA.config[@"ContainerClipsToBounds"] boolValue];
    containerView.clipsToBounds = isContainerClipsToBounds;   // Comment it for test , in production , open it .
    if (! isContainerClipsToBounds) {
        [QueuePositionsHelper refreshRectsPositionsRepositoryWhenClipsToBoundsIsNO:visualFrame];
    }
    
    
    [IterateHelper iterateTwoDimensionArray: QueueViewsHelper.viewsInVisualArea handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
        SymbolView* symbolView = (SymbolView*)obj;
        symbolView.row = (int)outterIndex;
        symbolView.column = (int)innerIndex;
        return NO;
    }];
    
}

-(void) initializeNewToContainerSymbolsPrototypesAppearance
{
    // set up all symbols attributes
    UIView* containerView = VIEW.gameView.containerView;
    NSArray* viewRepository = QueueViewsHelper.viewsRepository;
    NSArray* rectsRepository = QueuePositionsHelper.rectsRepository;
    [IterateHelper iterateTwoDimensionArray:viewRepository handler:^BOOL(NSUInteger outterIndex, NSUInteger innerIndex, id obj, NSUInteger outterCount, NSUInteger innerCount) {
        SymbolView* symbolView = (SymbolView*)obj;
        
        // the new symbols
        if (!symbolView.superview) {
            // cause it's new , so should restore
            [symbolView restore];
            
            [containerView addSubview: symbolView];
            
            symbolView.frame = [rectsRepository[outterIndex][innerIndex] CGRectValue];
            [symbolView setValidArea: symbolView.bounds];
            
            symbolView.name = [ACTION.gameState oneRandomSymbolName];
        }
        return NO;
    }];
}


@end
