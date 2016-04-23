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
        
        UISwipeGestureRecognizer* swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightAction:)];
        swipeGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
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

-(void) swipeRightAction: (UISwipeGestureRecognizer*)sender
{
    ACTION.gameState.isMuteMusic = !ACTION.gameState.isMuteMusic;
    [APPStandUserDefaults setObject:@(ACTION.gameState.isMuteMusic) forKey:@"isMusicDisable"];
    NSString* actionKey = ACTION.gameState.isMuteMusic ? @"PauseActions" : @"ResumeActions";
    NSDictionary* fadeSpecifications = [ConfigHelper getMusicConfig: actionKey];
    [VIEW.actionExecutorManager runAudioActionExecutors:fadeSpecifications];
}

#pragma mark - LineScrollViewDataSource Methods

-(void)lineScrollView:(LineScrollView *)lineScrollViewObj willShowIndex:(int)index isReload:(BOOL)isReload
{
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


