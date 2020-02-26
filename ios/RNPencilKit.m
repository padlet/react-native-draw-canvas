//
//  RNPencilKit.m
//  Dreamcatcher
//
//  Created by Colin Teahan on 2/24/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "RNPencilKit.h"
#import "UIImage+resize2.h"

API_AVAILABLE(ios(13.0))
@interface RNPencilKit()
{
  UIColor *backgroundColor;
  UIUserInterfaceStyle currentStyle;
}

@property (strong, nonatomic) PKCanvasView *canvas;
@property (strong, nonatomic) PKToolPicker *picker;

@end

@implementation RNPencilKit

@synthesize canvas, picker;

RCT_EXPORT_MODULE()

// React native method
+ (BOOL)requiresMainQueueSetup
{
  return true;
}

- (id)init {
  if (self = [super init])
  {
    backgroundColor = [UIColor whiteColor];
    self.canvas = [[PKCanvasView alloc] initWithFrame:self.frame];
    [self.canvas setUserInteractionEnabled:true];
    [self.canvas setAutoresizesSubviews:true];
    [self.canvas setAutoresizingMask:
     UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleHeight];
    [self.canvas setAllowsFingerDrawing:true];
    [self.canvas setDelegate:self];
    [self setToolPicker];
    [self setLightMode];
    [self setAutoresizesSubviews:true];
    [self setAutoresizingMask:
     UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleHeight];
    [self addSubview:self.canvas];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGRect layoutFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
  [self.canvas setFrame:layoutFrame];
}

//- (UIView *)view API_AVAILABLE(ios(13)) {
//  RCTLogInfo(@"[RNPencilKit] creating view!");
//  self.canvas = [[PKCanvasView alloc] init];
//  PKInkingTool *pen = [[PKInkingTool alloc] initWithInkType:PKInkTypePen color:[UIColor blackColor]];
//  [self.canvas setTool:pen];
//  [self.canvas setUserInteractionEnabled:true];
//  [self.canvas setAllowsFingerDrawing:true];
//  [self.canvas setDelegate:self];
//  [self setToolPicker];
//  return self.canvas;
//}

- (void)setToolPicker API_AVAILABLE(ios(13)) {
  RCTLogInfo(@"[RNPencilKit] creating tool bar!");
  UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
  self.picker = [PKToolPicker sharedToolPickerForWindow:window];
  [self.picker addObserver:self.canvas];
  [self.picker setVisible:true forFirstResponder:self.canvas];
  [self.canvas becomeFirstResponder];
}

- (void)resetToolPicker {
  //[self.picker setV]
}

- (void)canvasViewDrawingDidChange:(PKCanvasView *)canvasView API_AVAILABLE(ios(13)) {
  //RCTLogInfo(@"[RNPencilKit] canvas view drawing did change...");
}

- (void)canvasViewDidBeginUsingTool:(PKCanvasView *)canvasView API_AVAILABLE(ios(13)) {
  //RCTLogInfo(@"[RNPencilKit] did begin using tool...");
}

- (void)drawing:(void(^)(NSDictionary *data))completion API_AVAILABLE(ios(13)) {
  //  PKDrawing *drawing = [self.canvas drawing];
  //
  //
  //  NSData *data = [drawing dataRepresentation];
  //  RCTLogInfo(@"[DrawingData] data: %@", data);
  //
  //  UIImage *image = [drawing imageFromRect:self.bounds scale:1.0];
  [self takeScreenshot:^(UIImage *image) {
    completion([self saveImageToDisk:image]);
  }];
}

/**
 This method takes the image returned by the canvas view and inverts all whites to black if the current user interface style is light or all blacks to white if the
 current style is dark mode. Then this adds a background to the transparent picture
 
 */
- (NSDictionary *)saveImageToDisk:(UIImage *)image API_AVAILABLE(ios(11.0)){
  NSData *imageData = UIImageJPEGRepresentation(image, 0.95);
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"yyyy-MM-dd-HH-mm"];
  NSString *name = [NSString stringWithFormat:@"drawing-%@.png",[dateFormat stringFromDate:[NSDate date]]];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:name];
  [imageData writeToFile:filePath atomically:true];
  CGFloat fileSize = imageData.length / 1024.0f / 1024.0f;
  UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
  return @{ @"uri":filePath, @"fileSize":@(fileSize), @"name":name };
}

- (UIUserInterfaceStyle)getCurrentUserInterfaceStyle {
  return [UITraitCollection currentTraitCollection].userInterfaceStyle;
}

- (void)takeScreenshot:(void(^)(UIImage *image))completion {
  // seems to be a bit of heisenbug here, this log statement fixes an issue with the bounds
  RCTLogInfo(@"[RNPencilKit] taking screenshot: (%f, %f)", self.canvas.bounds.size.width, self.canvas.bounds.size.height);
  RCTLogInfo(@"[RNPencilKit] taking screenshot (frame): (%f, %f)", self.canvas.frame.size.width, self.canvas.frame.size.height);
  CGSize sc = [[UIScreen mainScreen] bound].size;
  RCTLogInfo(@"[RNPencilKit] screen width: %f height: %f", sc.width, sc.height);
  RCTLogInfo(@"[RNPencilKit] scale %lf", [UIScreen mainScreen].scale);
  UIGraphicsBeginImageContextWithOptions(self.canvas.bounds.size, false, [UIScreen mainScreen].scale);
  [self drawViewHierarchyInRect:self.canvas.bounds afterScreenUpdates:true];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  completion(image);
}

- (void)setDarkMode {
  currentStyle = UIUserInterfaceStyleDark;
  backgroundColor = [UIColor blackColor];
  [self updateInterfaceStyle];
}

- (void)setLightMode {
  currentStyle = UIUserInterfaceStyleLight;
  backgroundColor = [UIColor whiteColor];
  [self updateInterfaceStyle];
}

- (void)undo {
  [[self.canvas undoManager] undo];
}

- (void)redo {
  [[self.canvas undoManager] redo];
}

- (void)updateInterfaceStyle {
  if (self.picker) {
    if ([self.picker respondsToSelector:@selector(setColorUserInterfaceStyle:)])
      [self.picker setColorUserInterfaceStyle:currentStyle];
    if ([self.picker respondsToSelector:@selector(setOverrideUserInterfaceStyle:)])
      [self.picker setOverrideUserInterfaceStyle:currentStyle];
  }
  if (self.canvas) {
    if ([self.canvas respondsToSelector:@selector(setOverrideUserInterfaceStyle:)])
      [self.canvas setOverrideUserInterfaceStyle:currentStyle];
  }
}

- (void)invertColors {
  PKDrawing *drawing = [self.canvas drawing];
  UIImage *image = [drawing imageFromRect:self.bounds scale:1.0];
  
  if (currentStyle == UIUserInterfaceStyleDark)
    image = [image invert:false black:true];
  else
    image = [image invert:true black:false];
  
  NSError *error;
  PKDrawing *newDrawing = [[PKDrawing alloc] initWithData:UIImagePNGRepresentation(image) error:&error];
  RCTLogInfo(@"[RNPencilKit] created new drawing: %@", error);
  
  [self.canvas setDrawing:newDrawing];
}

- (void)displayMethods:(id)object {
  RCTLogInfo(@"[XCODE] Displaying methods...");
  unsigned int count = 0;
  Method *methods = class_copyMethodList(object_getClass(object), &count);
  RCTLogInfo(@"[XCODE] Found %d methods on %@",count,[object description]);
  for (int i=0; i<count; i++) RCTLogInfo(@"[XCODE] Method #%3d: %s", i, sel_getName(method_getName(methods[i])));
}

- (void)displayProperties:(id)object {
  RCTLogInfo(@"[XCODE] Displaying methods...");
  unsigned int count = 0;
  objc_property_t *properties = class_copyPropertyList(object_getClass(object), &count);
  
  RCTLogInfo(@"[XCODE] Found %d methods on %@",count,[object description]);
  for (int i=0; i<count; i++) {
    objc_property_t property = properties[i];
    NSString *propertyName = [NSString stringWithFormat:@"%s", property_getName(property)];
    RCTLogInfo(@"[XCODE]: property name: %@", propertyName);
  }
}


- (void)displaySubviews:(UIView *)view {
  for (UIView *subview in view.subviews) {
    RCTLogInfo(@"[XCODE] subviews: %@", subview);
  }
}

@end

