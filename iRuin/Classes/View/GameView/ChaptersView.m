#import "ChaptersView.h"
#import "AppInterface.h"

@interface ChaptersView() <LineScrollViewDataSource>

@end

@implementation ChaptersView
{    
    NSMutableDictionary* imagesCache;
}


@synthesize lineScrollView;

@synthesize cueLabel;

@synthesize cueLabelShimmerView;



-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // images caches
        imagesCache = [NSMutableDictionary dictionary];
        
        // chapters cell views
        lineScrollView = [[LineScrollView alloc] init];
        [lineScrollView registerCellClass: [ImageLabelLineScrollCell class]];
        lineScrollView.dataSource = self;
        [self addSubview: lineScrollView];
        
        
        // cue label
        cueLabel = [[GradientLabel alloc] init];
        cueLabelShimmerView = [[FBShimmeringView alloc] init];
        cueLabelShimmerView.contentView = cueLabel;
        [self addSubview:cueLabelShimmerView];
        
        
        // add swipe gesture
        UISwipeGestureRecognizer* swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        swipeGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        UISwipeGestureRecognizer* swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        swipeGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [cueLabelShimmerView addGestureRecognizer:swipeGestureRight];
        [cueLabelShimmerView addGestureRecognizer:swipeGestureLeft];
    }
    return self;
}


#pragma mark - Swipe Gesture Action

-(void) swipeAction: (UISwipeGestureRecognizer*)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        
        ACTION.gameState.isMuteMusic = !ACTION.gameState.isMuteMusic;
        
        NSDictionary* audioPlayers = ((AudiosExecutor*)[VIEW.actionExecutorManager getActionExecutor: effect_AUDIO]).audiosPlayers;
        NSDictionary* fadeSpecifications = DATA.config[@"FadeActions"];
        for (NSString* key in fadeSpecifications) {
            AVAudioPlayer* player = audioPlayers[key];
            NSDictionary* dictionary = fadeSpecifications[key];
            NSDictionary* dic = ACTION.gameState.isMuteMusic ? dictionary[@"OFF"]: dictionary[@"ON"];
            float toVolume = [dic[@"fadeToVolume"] floatValue];
            float overDuration = [dic[@"fadeOverDuration"] floatValue];
            [[AudioHandler audioCrossFadeQueue] addOperation:[[MXAudioPlayerFadeOperation alloc] initFadeWithAudioPlayer:player toVolume:toVolume overDuration:overDuration]];
        }
        
        NSArray* values = DATA.config[@"Utilities"][@"AudioCues"];
        
        NSString* cueText = ACTION.gameState.isMuteMusic ? [values lastObject] : [values firstObject];
        if (cueText) {
            
            // change text with animation
            CATransition *animation = [CATransition animation];
            animation.duration = 0.5;
            animation.type = kCATransitionFromTop;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [cueLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
            
            cueLabel.text = cueText;
        }
        
    } else if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        
        // change text with animation
        CATransition *animation = [CATransition animation];
        animation.duration = 0.5;
        animation.type = kCATransitionFromTop;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [cueLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
        
        cueLabel.text = nil;
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
    
    int circel = [chapterCellsConfig[@"Chapters_Cells_Circle"] intValue];
    NSDictionary* specifications = chapterCellsConfig[@"Chapters_Cells"];
    
    int i = abs(index) % circel;
    NSString* iKey = [NSString stringWithFormat:@"%d", i];
    NSString* indexKey = [NSString stringWithFormat: @"%d", index];
    NSDictionary* config = specifications[indexKey] ? specifications[indexKey] : specifications[iKey];
    NSDictionary* imageConfig = config[@"image"] ;
    if (!imageConfig) {
        imageConfig = specifications[@"default"][@"image"];
    }
    NSDictionary* labelConfig = config[@"label"] ;
    if (!labelConfig) {
        labelConfig = specifications[@"default"][@"label"];
    }
    
    // image
    NSString* imageName = imageConfig[@"image"];
    UIImage* image = imagesCache[imageName];
    if (! image) {
        image = [KeyValueCodingHelper getUIImageByPath: imageName];
        if (image) [imagesCache setObject: image forKey:imageName];
    }
    
    // imageView
    UIImageView* imageView = cell.imageView;
    imageView.image = image;
    
    // for optimize the following 'designateValuesActionsTo'
    [DictionaryHelper replaceKey: (NSMutableDictionary*)imageConfig key:@"image" withKey:@"image_"];
    [ACTION.gameEffect designateValuesActionsTo: imageView config: imageConfig];
    [DictionaryHelper replaceKey: (NSMutableDictionary*)imageConfig key:@"image_" withKey:@"image"];
    
    
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


