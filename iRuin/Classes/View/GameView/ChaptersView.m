#import "ChaptersView.h"
#import "AppInterface.h"

@interface ChaptersView() <LineScrollViewDataSource>

@end

@implementation ChaptersView
{    
    NSMutableDictionary* imagesCache;
}


@synthesize lineScrollView;

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // chapter views
        lineScrollView = [[LineScrollView alloc] init];
        [lineScrollView registerCellClass: [ImageLabelLineScrollCell class]];
        lineScrollView.dataSource = self;
        [self addSubview: lineScrollView];
        
        imagesCache = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - LineScrollViewDataSource Methods

-(void)lineScrollView:(LineScrollView *)lineScrollViewObj willShowIndex:(int)index
{
    ImageLabelLineScrollCell* cell = (ImageLabelLineScrollCell*)[lineScrollViewObj visibleCellAtIndex: index];
    
    int circel = [DATA.config[@"Chapters_Cells_Circle"] intValue];
    NSDictionary* specifications = DATA.config[@"Chapters_Cells"];
    
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
        image = [KeyValueCodingHelper getUIImage: imageName];
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
}


-(void)lineScrollView:(LineScrollView *)lineScrollView didSelectIndex:(int)index
{
    ACTION.gameState.currentChapter = index;
    [ACTION.gameEvent gameStart];
}

@end
