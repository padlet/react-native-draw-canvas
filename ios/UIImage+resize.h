//
//  UIImage+resize.h
//  DrawCanvas
//
//  Created by Colin Teahan on 2/26/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface UIImage (resize)

- (UIImage *)normalizedImage;
- (UIImage *)invert:(BOOL)invertWhite black:(BOOL)invertBlack;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
- (UIImage *)imageWithContrast:(CGFloat)contrastFactor;
- (UIImage *)imageWithContrast:(CGFloat)contrastFactor brightness:(CGFloat)brightnessFactor;
- (UIImage *)setBackgroundColor:(UIColor *)tintColor;
- (UIImage *)withBackground:(UIColor *)color;

@end
