// http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload



#import <UIKit/UIKit.h>

@interface UIImage(fixOrientation)
- (UIImage *)fixOrientation;
@end

@interface UIImage(setOrientation)
- (UIImage *)setOrientation:(UIImageOrientation) orientation;
@end


@interface UIImage(rotateImage)
- (UIImage *)rotateImage:(UIImage *)image onDegrees:(float)degrees;
@end
