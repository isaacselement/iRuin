#import <UIKit/UIKit.h>

@interface InteractiveImageView : UIImageView


@property (assign) BOOL enableSelected;

@property (assign, nonatomic, getter=isSelected) BOOL selected;

@property (strong) UIImage* selectedImage;

@property (strong) UIImage* selectedHighlightedImage;

@property (copy) void(^didEndTouchAction)(InteractiveImageView* actionView);



@end
