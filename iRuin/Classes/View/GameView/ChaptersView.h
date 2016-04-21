#import "GameBaseView.h"


@class LineScrollView;

@interface ChaptersView : GameBaseView


@property (strong, readonly) LineScrollView* lineScrollView;

@property (strong, readonly) UIView* musicActionView;


@end
