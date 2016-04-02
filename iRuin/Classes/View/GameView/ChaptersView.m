#import "ChaptersView.h"
#import "AppInterface.h"

@interface ChaptersView() <LineScrollViewDataSource>

@end

@implementation ChaptersView


@synthesize lineScrollView;

@synthesize muteBGMActionView;


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // mute BMG action
        muteBGMActionView = [[UIView alloc] init];
        [self addSubview:muteBGMActionView];
        
        UISwipeGestureRecognizer* swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightAction:)];
        swipeGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [muteBGMActionView addGestureRecognizer:swipeGestureRight];
        
        // chapters cell views
        lineScrollView = [[LineScrollView alloc] init];
        [lineScrollView registerCellClass: [ImageLabelLineScrollCell class]];
        lineScrollView.dataSource = self;
        [self addSubview: lineScrollView];
    }
    return self;
}


#pragma mark - Swipe Gesture Action

-(void) swipeRightAction: (UISwipeGestureRecognizer*)sender
{
    ACTION.gameState.isMuteMusic = !ACTION.gameState.isMuteMusic;
    NSDictionary* audioPlayers = ((AudiosExecutor*)[VIEW.actionExecutorManager getActionExecutor: effect_AUDIO]).audiosPlayers;
    NSDictionary* fadeSpecifications = DATA.config[@"FadeActions"];
    for (NSString* key in fadeSpecifications) {
        AVAudioPlayer* player = audioPlayers[key];
        if (!player) return;
        
        NSDictionary* spec = fadeSpecifications[key];
        NSDictionary* dic = ACTION.gameState.isMuteMusic ? spec[@"OFF"]: spec[@"ON"];
        float toVolume = [dic[@"fadeToVolume"] floatValue];
        float overDuration = [dic[@"fadeOverDuration"] floatValue];
        MXAudioPlayerFadeOperation* fadeOperation = [[MXAudioPlayerFadeOperation alloc] initFadeWithAudioPlayer:player toVolume:toVolume overDuration:overDuration];
        [[AudioHandler audioCrossFadeQueue] addOperation: fadeOperation];
    }
}

#pragma mark - LineScrollViewDataSource Methods

-(void)lineScrollView:(LineScrollView *)lineScrollViewObj willShowIndex:(int)index isReload:(BOOL)isReload
{
    // -------------- mute the sound on reload Begin
    if (isReload) {
        ((AudiosExecutor*)[VIEW.actionExecutorManager getActionExecutor: effect_AUDIO]).disableAudio = YES;
    }
    
     
    ImageLabelLineScrollCell* cell = (ImageLabelLineScrollCell*)[lineScrollViewObj visibleCellAtIndex: index];
    
    NSDictionary* chapterCellsConfig = DATA.config[@"CHAPTERS_WILL_SHOW"];
    
    NSDictionary* specifications = chapterCellsConfig[@"Chapters_Cells"];
    NSDictionary* imageSpecifications = specifications[@"image"];
    NSDictionary* labelSpecifications = specifications[@"label"];

    NSDictionary* imageConfig = [ConfigHelper getSubConfigWithLoop:imageSpecifications index:index];
    NSDictionary* labelConfig = [ConfigHelper getSubConfigWithLoop:labelSpecifications index:index];
    
    // imageView
    UIImageView* imageView = cell.imageView;
    [ACTION.gameEffect designateValuesActionsTo: imageView config: imageConfig];
    // index label
    GradientLabel* label = cell.label;
    [ACTION.gameEffect designateValuesActionsTo: label config:labelConfig];
    label.text = [NSString stringWithFormat:@"%d", index];
    
    // change the font to fix , cause the previous 'designate' will set font again
    while ( [label.text sizeWithAttributes:@{NSFontAttributeName: label.font}].width > (label.frame.size.width - CanvasW(50))) {
        label.font = [label.font fontWithSize: (label.font.pointSize - 8)];
        // be aware of infinite loop
        if (label.font.pointSize < 8) {
            break;
        }
    }
    
    
    // -------------- mute the sound on reload End
    if (isReload) {
        ((AudiosExecutor*)[VIEW.actionExecutorManager getActionExecutor: effect_AUDIO]).disableAudio = NO;
    }
}



-(void)lineScrollView:(LineScrollView *)lineScrollViewObj touchBeganAtPoint:(CGPoint)point
{
    LineScrollViewCell* cell = (LineScrollViewCell*)[lineScrollViewObj hitTest:point withEvent:nil];
    if (!cell || ![cell isKindOfClass:[LineScrollViewCell class]]) return;
    
    // chapters cell effect
    [ACTION.gameEffect designateValuesActionsTo:cell config:DATA.config[@"Chapter_Cell_TouchBegan"]];
}



-(void)lineScrollView:(LineScrollView *)lineScrollViewObj touchEndedAtPoint:(CGPoint)point
{
    ImageLabelLineScrollCell* cell = (ImageLabelLineScrollCell*)[lineScrollViewObj hitTest:point withEvent:nil];
    if (!cell || ![cell isKindOfClass:[LineScrollViewCell class]]) return;
    
    // chapters cell effect
    [ACTION.gameEffect designateValuesActionsTo:cell config:DATA.config[@"Chapter_Cell_TouchEnded"]];
    
    
    // -------------------------- ++++++++++++++ -----------------------
    
    // --------------------- index
    int index = [lineScrollViewObj indexOfVisibleCell: cell];
    ACTION.gameState.currentChapter = index;
    
    
    // --------------------- mode
    int switchModeCount = [DATA.config[@"Utilities"][@"SwitchModeEveryChapters"] intValue];
    if (switchModeCount == 0) switchModeCount = 1;
    int modeCount = (int)ACTION.gameModes.count;
    int modeIndex = (abs(index) % (modeCount * switchModeCount)) % modeCount;
    NSString* mode = [ACTION.gameModes safeObjectAtIndex: modeIndex];
    ACTION.gameState.currentMode = mode;

    // switch config by mode and index
    NSString* indexString = [NSString stringWithFormat:@"%d", index];
    UILabel* label = VIEW.gameView.seasonLabel;
    label.text = StringAppend(@"Season ", indexString);
    [label adjustFontSizeToWidth];
    
    [ACTION.gameEvent gameStart];
}

@end


