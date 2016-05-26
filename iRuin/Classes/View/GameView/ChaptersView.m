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
        BOOL isMuteMusic = [[APPStandUserDefaults objectForKey:@"isMusicDisable"] boolValue];
        isMuteMusic = !isMuteMusic;
        [APPStandUserDefaults setObject:@(isMuteMusic) forKey:@"isMusicDisable"];
        isMuteMusic ? [ACTION.gameEvent pauseBackgroundMusic] : [ACTION.gameEvent resumeBackgroundMusic];
        
    } else if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        [ACTION.gameEvent stopBackgroundMusic];
        [ACTION.gameEvent playNextBackgroundMusic];
        
    }
}

#pragma mark - LineScrollViewDataSource Methods

-(BOOL)lineScrollView:(LineScrollView *)lineScrollView shouldShowIndex:(int)index isReload:(BOOL)isReload
{
    NSInteger minimalIndex = NSIntegerMin;
    if ([ConfigHelper getUtilitiesConfig:@"ChaptersMinimalIndex"]) {
        minimalIndex = [[ConfigHelper getUtilitiesConfig:@"ChaptersMinimalIndex"] intValue];
    }
    NSInteger maximalIndex = [[APPStandUserDefaults objectForKey:User_ChapterIndex] intValue];
    return index >= minimalIndex && index <= maximalIndex;
}

-(void)lineScrollView:(LineScrollView *)lineScrollViewObj willShowIndex:(int)index isReload:(BOOL)isReload
{
    DLOG(@"willShowIndex : %d", index);
    // -------------- mute the sound on reload Begin
    if (isReload) {
        ((AudiosExecutor*)[VIEW.actionExecutorManager getActionExecutor: effect_AUDIO]).disableAudio = YES;
    }
    
    ImageLabelLineScrollCell* cell = (ImageLabelLineScrollCell*)[lineScrollViewObj visibleCellAtIndex: index];
    NSDictionary* chapterCellsConfig = [ConfigHelper getLoopConfig:DATA.config[@"Chapters_Cells_In_Touch_Rolling"] index:index] ;
    
    [ACTION.gameEffect designateValuesActionsTo: cell config:chapterCellsConfig];
    
    GradientLabel* label = cell.label;
    label.text = [NSString stringWithFormat:@"%d", index];
    [label adjustFontSizeToWidthWithGap: CanvasW(50)];
    
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
    [ACTION.gameEffect designateValuesActionsTo:cell config:DATA.config[@"Chapter_Cell_In_Touch_Began"]];
}

-(void)lineScrollView:(LineScrollView *)lineScrollViewObj touchEndedAtPoint:(CGPoint)point
{
    ImageLabelLineScrollCell* cell = (ImageLabelLineScrollCell*)[lineScrollViewObj hitTest:point withEvent:nil];
    if (!cell || ![cell isKindOfClass:[LineScrollViewCell class]]) return;
    
    // chapters cell effect
    [ACTION.gameEffect designateValuesActionsTo:cell config:DATA.config[@"Chapter_Cell_In_Touch_Ended"]];
    
    // --------------------- index
    int index = [lineScrollViewObj indexOfVisibleCell: cell];
    ACTION.gameState.currentChapter = index;
    
    // --------------------- mode
    ACTION.gameState.currentMode = [[ConfigHelper getSupportedModes] firstObject];

    // switch config by mode and index
    NSString* indexString = [NSString stringWithFormat:@"%d", index];
    UILabel* label = VIEW.gameView.seasonLabel;
    label.text = StringAppend(@"Season ", indexString);
    [label adjustFontSizeToWidth];
    
    [ACTION.gameEvent gameStart];
}

@end


