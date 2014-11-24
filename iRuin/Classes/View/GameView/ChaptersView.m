#import "ChaptersView.h"
#import "AppInterface.h"

@interface ChaptersView() <LineScrollViewDataSource>

@end

@implementation ChaptersView
{    
    NSMutableDictionary* imagesCache;
}


@synthesize lineScrollView;

@synthesize muteActionView;



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
        
        // mute action view
        muteActionView = [[InteractiveView alloc] init];
        muteActionView.imageView.enableSelected = YES;
        muteActionView.imageView.didEndTouchAction = ^void(InteractiveImageView* view){
            
            BOOL isMute = view.selected;
            NSDictionary* audioPlayers = ((AudiosExecutor*)[VIEW.actionExecutorManager getActionExecutor: effect_AUDIO]).audiosPlayers;
            NSDictionary* fadeSpecifications = DATA.config[@"FadeActions"];
            for (NSString* key in fadeSpecifications) {
                AVAudioPlayer* player = audioPlayers[key];
                NSDictionary* dictionary = fadeSpecifications[key];
                NSDictionary* dic = isMute ? dictionary[@"OFF"]: dictionary[@"ON"];
                float toVolume = [dic[@"fadeToVolume"] floatValue];
                float overDuration = [dic[@"fadeOverDuration"] floatValue];
                [[AudioHandler audioCrossFadeQueue] addOperation:[[MXAudioPlayerFadeOperation alloc] initFadeWithAudioPlayer:player toVolume:toVolume overDuration:overDuration]];
            }
            
        };
        [self addSubview: muteActionView];
    }
    return self;
}

#pragma mark - LineScrollViewDataSource Methods

-(void)lineScrollView:(LineScrollView *)lineScrollViewObj willShowIndex:(int)index isReload:(BOOL)isReload
{
    // mute the sound on launch
    ((AudiosExecutor*)[VIEW.actionExecutorManager getActionExecutor: effect_AUDIO]).disable = isReload;
     
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
    
    
    // ---------------------
    int index = [lineScrollViewObj indexOfVisibleCell: cell];
    ACTION.gameState.currentChapter = index;
    
    int switchModeCount = [DATA.config[@"Utilities"][@"SwitchModeChapters"] intValue];
    if (switchModeCount == 0) switchModeCount = 1;
    int modeCount = ACTION.gameModes.count;
    int modeIndex = (index % (modeCount * switchModeCount)) / modeCount;
    NSString* mode = [ACTION.gameModes safeObjectAtIndex: modeIndex];
    [ACTION switchToMode: mode];
    
    NSString* indexString = [NSString stringWithFormat:@" %d", index];
    VIEW.gameView.seasonLabel.text = StringAppend(@"Season", indexString);
    
    [ACTION.gameEvent gameStart];
}

@end


