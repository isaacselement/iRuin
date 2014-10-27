#import "InteractiveImageView.h"

@implementation InteractiveImageView
{
    BOOL _selected;
    UIImage* _normalImage;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // save the original image
    if (!_normalImage) {
        _normalImage = self.image;
    }
    
    if (_selected) {
        if (self.selectedHighlightedImage) self.image = self.selectedHighlightedImage;
    } else {
        self.highlighted = YES;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
    
    CGPoint point = [[touches anyObject] locationInView: self];
    BOOL isTouchInView = CGRectContainsPoint(self.bounds, point);
    if (isTouchInView) {
        
        _selected = !_selected;
        if (_selected) {
            if (self.selectedImage) self.image = self.selectedImage;
        } else {
            self.image = _normalImage;
        }
        
        // call the action
        if (self.didEndTouchAction) {
            self.didEndTouchAction(self);
        }
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}


-(BOOL) isSelected
{
    return _selected;
}

@end
