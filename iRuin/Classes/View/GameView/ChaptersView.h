#import "GameBaseView.h"


@class LineScrollView;
@class InteractiveView;


@interface ChaptersView : GameBaseView



@property (strong, readonly) LineScrollView* lineScrollView;

@property (strong, readonly) InteractiveView* muteActionView;



@end
