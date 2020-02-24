//
//  RNPencilKitManager.m
//  Dreamcatcher
//
//  Created by Colin Teahan on 2/24/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "RNPencilKitManager.h"
#import "RNPencilKit.h"

@interface RNPencilKitManager()

@property (strong, nonatomic) RNPencilKit *pencilKit;

@end

@implementation RNPencilKitManager

@synthesize pencilKit;

RCT_EXPORT_MODULE()

- (NSDictionary *)constantsToExport
{
  if (@available(iOS 13.0, *))
  {
    return @{ @"available": @(true) };
  } else {
    return @{ @"available": @(false) };
  }
}

- (UIView *)view
{
  return [[RNPencilKit alloc] init];
}

+ (BOOL)requiresMainQueueSetup
{
  return true;
}

RCT_EXPORT_METHOD(getDrawing:(nonnull NSNumber *)reactTag withCallback:(RCTResponseSenderBlock)callback) {
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
    RNPencilKit *view = (RNPencilKit *)viewRegistry[reactTag];
    if (!view || ![view isKindOfClass:[RNPencilKit class]]) {
      RCTLogWarn(@"[RNPencilViewManager] Cannot find NativeView with tag #%@", viewRegistry);
      return;
    }
    RCTLogInfo(@"[RNPencilViewManager] getting drawing...");
    [view drawing:^(NSDictionary * _Nonnull data) {
      callback(@[data]);
    }];
  }];
}

RCT_EXPORT_METHOD(setToolPicker:(nonnull NSNumber *)reactTag) {
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
    RNPencilKit *view = (RNPencilKit *)viewRegistry[reactTag];
    if (!view || ![view isKindOfClass:[RNPencilKit class]]) {
      RCTLogWarn(@"[RNPencilViewManager] Cannot find NativeView with tag #%@", viewRegistry);
      return;
    }
    RCTLogInfo(@"[RNPencilViewManager] setting tool picker...");
    [view setToolPicker];
  }];
}

RCT_EXPORT_METHOD(setDarkMode:(nonnull NSNumber *)reactTag) {
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
    RNPencilKit *view = (RNPencilKit *)viewRegistry[reactTag];
    if (!view || ![view isKindOfClass:[RNPencilKit class]]) {
      RCTLogWarn(@"[RNPencilViewManager] Cannot find NativeView with tag #%@", viewRegistry);
      return;
    }
    RCTLogInfo(@"[RNPencilViewManager] setting tool picker...");
    [view setDarkMode];
  }];
}

RCT_EXPORT_METHOD(setLightMode:(nonnull NSNumber *)reactTag) {
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
    RNPencilKit *view = (RNPencilKit *)viewRegistry[reactTag];
    if (!view || ![view isKindOfClass:[RNPencilKit class]]) {
      RCTLogWarn(@"[RNPencilViewManager] Cannot find NativeView with tag #%@", viewRegistry);
      return;
    }
    RCTLogInfo(@"[RNPencilViewManager] setting tool picker...");
    [view setLightMode];
  }];
}

RCT_EXPORT_METHOD(undo:(nonnull NSNumber *)reactTag) {
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
    RNPencilKit *view = (RNPencilKit *)viewRegistry[reactTag];
    if (!view || ![view isKindOfClass:[RNPencilKit class]]) {
      RCTLogWarn(@"[RNPencilViewManager] Cannot find NativeView with tag #%@", viewRegistry);
      return;
    }
    RCTLogInfo(@"[RNPencilViewManager] undo...");
    [view undo];
  }];
}

RCT_EXPORT_METHOD(redo:(nonnull NSNumber *)reactTag) {
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
    RNPencilKit *view = (RNPencilKit *)viewRegistry[reactTag];
    if (!view || ![view isKindOfClass:[RNPencilKit class]]) {
      RCTLogWarn(@"[RNPencilViewManager] Cannot find NativeView with tag #%@", viewRegistry);
      return;
    }
    RCTLogInfo(@"[RNPencilViewManager] undo...");
    [view redo];
  }];
}

@end
