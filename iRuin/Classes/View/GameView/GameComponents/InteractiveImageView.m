#import "InteractiveImageView.h"

@implementation InteractiveImageView
{
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
    
    
    // touch begin, highlighted

    if (self.enableSelected && self.selected) {
        [self setSelectedHighlighted: YES];
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
        
        // change selected status
        if (self.enableSelected) {
            self.selected = !self.selected;
            [self setSelectedHighlighted: NO];
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


-(void) setSelectedHighlighted: (BOOL)selectedHighlighted
{
    if (selectedHighlighted) {
        if (self.selectedHighlightedImage) self.image = self.selectedHighlightedImage;
    } else {
        self.image = self.selectedImage;
    }
}

-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    // chanage image
    if (_selected) {
        if (self.selectedImage) {
            if (self.selectedImage) self.image = self.selectedImage;
        }
    } else {
        if (self.image != _normalImage) self.image = _normalImage;
    }
}

#define transitionImageTime 0.2

-(void)setImage:(UIImage *)image
{
    // change image with transition
    [UIView transitionWithView: self duration:transitionImageTime options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [super setImage:image];
    } completion:nil];
}

-(void)setHighlighted:(BOOL)highlighted
{
    // change image with transition
    [UIView transitionWithView: self duration:transitionImageTime options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [super setHighlighted:highlighted];
    } completion:nil];
}

@end
