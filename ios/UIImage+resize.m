//
//  UIImage+resize.m
//  DrawCanvas
//
//  Created by Colin Teahan on 2/26/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "UIImage+resize.h"
#import <React/RCTLog.h>

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@implementation UIImage (resize)


- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
   // calculate the size of the rotated view's containing box for our drawing space
   UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
   CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
   rotatedViewBox.transform = t;
   CGSize rotatedSize = rotatedViewBox.frame.size;

   // Create the bitmap context
   UIGraphicsBeginImageContext(rotatedSize);
   CGContextRef bitmap = UIGraphicsGetCurrentContext();

   // Move the origin to the middle of the image so we will rotate and scale around the center.
   CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);

   //   // Rotate the image context
   CGContextRotateCTM(bitmap, DegreesToRadians(degrees));

   // Now, draw the rotated/scaled image into the context
   CGContextScaleCTM(bitmap, 1.0, -1.0);
   CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);

   UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   return newImage;

}


- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}


- (UIImage *)imageWithContrast:(CGFloat)contrastFactor {
  
    if ( contrastFactor == 1 ) {
        return self;
    }
  
    CGImageRef imgRef = [self CGImage];
  
    size_t width = CGImageGetWidth(imgRef);
    size_t height = CGImageGetHeight(imgRef);
  
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = 4;
    size_t bytesPerRow = bytesPerPixel * width;
    size_t totalBytes = bytesPerRow * height;
  
    //Allocate Image space
    uint8_t* rawData = malloc(totalBytes);
  
    //Create Bitmap of same size
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  
    //Draw our image to the context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
  
    //Perform Brightness Manipulation
    for ( int i = 0; i < totalBytes; i += 4 ) {
      
        uint8_t* red = rawData + i;
        uint8_t* green = rawData + (i + 1);
        uint8_t* blue = rawData + (i + 2);
      
        *red = MIN(255,MAX(0, roundf(contrastFactor*(*red - 127.5f)) + 128));
        *green = MIN(255,MAX(0, roundf(contrastFactor*(*green - 127.5f)) + 128));
        *blue = MIN(255,MAX(0, roundf(contrastFactor*(*blue - 127.5f)) + 128));
    
    }
  
    //Create Image
    CGImageRef newImg = CGBitmapContextCreateImage(context);
  
    //Release Created Data Structs
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(rawData);
  
    //Create UIImage struct around image
    UIImage* image = [UIImage imageWithCGImage:newImg];
  
    //Release our hold on the image
    CGImageRelease(newImg);
  
    //return new image!
    return image;
  
}

- (UIImage *)imageWithContrast:(CGFloat)contrastFactor brightness:(CGFloat)brightnessFactor {
  
    if ( contrastFactor == 1 && brightnessFactor == 0 ) {
        return self;
    }
  
    CGImageRef imgRef = [self CGImage];
  
    size_t width = CGImageGetWidth(imgRef);
    size_t height = CGImageGetHeight(imgRef);
  
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = 4;
    size_t bytesPerRow = bytesPerPixel * width;
    size_t totalBytes = bytesPerRow * height;
  
    //Allocate Image space
    uint8_t* rawData = malloc(totalBytes);
  
    //Create Bitmap of same size
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  
    //Draw our image to the context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
  
    //Perform Brightness Manipulation
    for ( int i = 0; i < totalBytes; i += 4 ) {
      
        uint8_t* red = rawData + i;
        uint8_t* green = rawData + (i + 1);
        uint8_t* blue = rawData + (i + 2);
      
        *red = MIN(255,MAX(0,roundf(*red + (*red * brightnessFactor))));
        *green = MIN(255,MAX(0,roundf(*green + (*green * brightnessFactor))));
        *blue = MIN(255,MAX(0,roundf(*blue + (*blue * brightnessFactor))));
      
        *red = MIN(255,MAX(0, roundf(contrastFactor*(*red - 127.5f)) + 128));
        *green = MIN(255,MAX(0, roundf(contrastFactor*(*green - 127.5f)) + 128));
        *blue = MIN(255,MAX(0, roundf(contrastFactor*(*blue - 127.5f)) + 128));
      
    }
  
    //Create Image
    CGImageRef newImg = CGBitmapContextCreateImage(context);
  
    //Release Created Data Structs
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(rawData);
  
    //Create UIImage struct around image
    UIImage* image = [UIImage imageWithCGImage:newImg];
  
    //Release our hold on the image
    CGImageRelease(newImg);
  
    //return new image!
    return image;
  
}


- (UIImage *)setBackgroundColor:(UIColor *)tintColor {
  UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextTranslateCTM(context, 0, self.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  CGContextSetBlendMode(context, kCGBlendModeNormal);
  CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
  CGContextClipToMask(context, rect, self.CGImage);
  [tintColor setFill];
  CGContextFillRect(context, rect);
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

- (UIImage *)withBackground:(UIColor *)color {
  UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
  CGContextSetFillColorWithColor(context, color.CGColor);
  CGContextFillRect(context, rect);
  CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, self.size.height));
  CGContextDrawImage(context, rect, self.CGImage);
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

- (UIImage *)invert:(BOOL)invertWhite black:(BOOL)invertBlack
{
    // get width and height as integers, since we'll be using them as
    // array subscripts, etc, and this'll save a whole lot of casting
    CGSize size = self.size;
    int width = size.width;
    int height = size.height;

    // Create a suitable RGB+alpha bitmap context in BGRA colour space
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *memoryPool = (unsigned char *)calloc(width*height*4, 1);
    CGContextRef context = CGBitmapContextCreate(memoryPool, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);

    // draw the current image to the newly created context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);

    // run through every pixel, a scan line at a time...
    for(int y = 0; y < height; y++)
    {
        // get a pointer to the start of this scan line
        unsigned char *linePointer = &memoryPool[y * width * 4];

        // step through the pixels one by one...
        for(int x = 0; x < width; x++)
        {
            // get RGB values. We're dealing with premultiplied alpha
            // here, so we need to divide by the alpha channel (if it
            // isn't zero, of course) to get uninflected RGB. We
            // multiply by 255 to keep precision while still using
            // integers
            int r, g, b;
            if(linePointer[3])
            {
                r = linePointer[0] * 255 / linePointer[3];
                g = linePointer[1] * 255 / linePointer[3];
                b = linePointer[2] * 255 / linePointer[3];
            }
            else
                r = g = b = 0;
          
            if (((r == 0 || g == 0 || b == 0) && invertBlack) || ((r == 255 || g == 255 || b == 255) && invertWhite)) {

              // perform the colour inversion
              r = 255 - r;
              g = 255 - g;
              b = 255 - b;

              if ( (r+g+b) / (3*255) == 0 )
              {
                  linePointer[0] = linePointer[1] = linePointer[2] = 0;
                  linePointer[3] = 0;
              }
              else
              {
                  // multiply by alpha again, divide by 255 to undo the
                  // scaling before, store the new values and advance
                  // the pointer we're reading pixel data from
                  linePointer[0] = r * linePointer[3] / 255;
                  linePointer[1] = g * linePointer[3] / 255;
                  linePointer[2] = b * linePointer[3] / 255;
              }
            }
          
            linePointer += 4;
        }
    }

    // get a CG image from the context, wrap that into a
    // UIImage
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];

    // clean up
    CGImageRelease(cgImage);
    CGContextRelease(context);
    free(memoryPool);

    // and return
    return returnImage;
}

@end
