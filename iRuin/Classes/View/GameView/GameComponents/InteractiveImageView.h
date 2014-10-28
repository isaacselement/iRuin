#import <UIKit/UIKit.h>

@interface InteractiveImageView : UIImageView


@property (strong) UIImage* selectedImage;

@property (strong) UIImage* selectedHighlightedImage;

@property (copy) void(^didEndTouchAction)(InteractiveImageView* actionView);




#pragma mark - Public Methods

-(BOOL) isSelected;



@end
