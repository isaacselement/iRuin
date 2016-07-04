#import "ChaptersView.h"
#import "AppInterface.h"

@interface ChaptersView() <LineScrollViewDataSource>

@end


@implementation ChaptersView


@synthesize lineScrollView;
@synthesize musicActionView;


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // mute BMG action
        musicActionView = [[UIView alloc] init];
        [self addSubview:musicActionView];
        
        UISwipeGestureRecognizer* swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        UISwipeGestureRecognizer* swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        swipeGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [musicActionView addGestureRecognizer:swipeGestureLeft];
        [musicActionView addGestureRecognizer:swipeGestureRight];
        
        // chapters cell views
        lineScrollView = [[LineScrollView alloc] init];
        [lineScrollView registerCellClass: [ImageLabelLineScrollCell class]];
        lineScrollView.dataSource = self;
        [self addSubview: lineScrollView];
    }
    return self;
}


#pragma mark - Swipe Gesture Action

-(void) swipeAction: (UISwipeGestureRecognizer*)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        [IRUserSetting sharedSetting].isMuteMusic = ![IRUserSetting sharedSetting].isMuteMusic;
        [IRUserSetting sharedSetting].isMuteMusic ? [EventHelper pauseBackgroundMusic] : [EventHelper resumeBackgroundMusic];
        
    } else if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        [EventHelper stopBackgroundMusic];
        [EventHelper playNextBackgroundMusic];
    }
}

#pragma mark - LineScrollViewDataSource Methods

-(BOOL)lineScrollView:(LineScrollView *)lineScrollView shouldShowIndex:(int)index isReload:(BOOL)isReload
{
    NSInteger minimalIndex = NSIntegerMin;
    if (DATA.config[@"ChaptersMinimalIndex"]) {
        minimalIndex = [DATA.config[@"ChaptersMinimalIndex"] intValue];
    }
    return index >= minimalIndex && index <= [IRUserSetting sharedSetting].chapter;
}

-(void)lineScrollView:(LineScrollView *)lineScrollViewObj willShowIndex:(int)index isReload:(BOOL)isReload
{
    // -------------- mute the sound on reload Begin
    if (isReload) {
        ((AudiosExecutor*)[VIEW.actionExecutorManager getActionExecutor: effect_AUDIO]).disableAudio = YES;
    }
    
    ImageLabelLineScrollCell* cell = (ImageLabelLineScrollCell*)[lineScrollViewObj visibleCellAtIndex: index];
    
    // start the lagest chapter effect
    if (index == [IRUserSetting sharedSetting].chapter) {
        [cell startMaskEffect];
    } else {
        [cell stopMaskEffect];
    }
    
    // touch rolling effect
    NSDictionary* chapterCellsConfig = [ConfigHelper getLoopConfig:DATA.config[@"Chapters_Cells_In_Touch_Rolling"] index:index] ;
    [ACTION.gameEffect designateValuesActionsTo:cell config:chapterCellsConfig];
    
    GradientLabel* label = cell.label;
    label.text = [NSString stringWithFormat:@"%d", index];
    [label adjustFontSizeToWidthWithGap: CanvasW(50)];
    
    // -------------- mute the sound on reload End
    if (isReload) {
        ((AudiosExecutor*)[VIEW.actionExecutorManager getActionExecutor: effect_AUDIO]).disableAudio = NO;
    }
    
}

-(void)lineScrollView:(LineScrollView *)lineScrollViewObj touchBeganAtCell:(LineScrollViewCell *)cell
{
    // chapters cell effect
    [ACTION.gameEffect designateValuesActionsTo:cell config:DATA.config[@"Chapter_Cell_In_Touch_Began"]];
}

-(void)lineScrollView:(LineScrollView *)lineScrollViewObj touchEndedAtCell:(LineScrollViewCell *)cell
{
    // chapters cell effect
    [ACTION.gameEffect designateValuesActionsTo:cell config:DATA.config[@"Chapter_Cell_In_Touch_Ended"]];
    
    // --------------------- chapter
    int index = [lineScrollViewObj indexOfVisibleCell: cell];
    int chapter = index;
    ACTION.gameState.currentChapter = chapter;
    
    // --------------------- mode
    // switch config by mode and index
    NSString* mode = [[ConfigHelper getSupportedModes] firstObject];
    ACTION.gameState.currentMode = mode;
    [ACTION switchToMode:mode chapter:chapter];
    
    // prepare the game views
    [[EffectHelper getInstance] startChapterCellsEffect: DATA.config[@"Chapters_Cells_In_Game_Start"]];
    [ACTION.gameEffect designateToControllerWithConfig: [ConfigHelper getLoopConfig:DATA.config[@"GAME_START"] index:chapter]];
    
    NSString* indexString = [NSString stringWithFormat:@"%d", chapter];
    UILabel* label = VIEW.gameView.seasonLabel;
    label.text = StringAppend(@"Season ", indexString);
    [label adjustFontSizeToWidth];
    
    [ACTION.gameEvent gameStart];
}

@end