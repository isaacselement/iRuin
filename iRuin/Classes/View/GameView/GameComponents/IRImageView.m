#import "IRImageView.h"

@implementation IRImageView

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, image.size.width, image.size.height);
}

@end
