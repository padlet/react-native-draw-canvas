//
//  RNPencilKit.h
//  Dreamcatcher
//
//  Created by Colin Teahan on 2/24/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTLog.h>
#import <PencilKit/PencilKit.h>
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTBridge.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(13.0))
@interface RNPencilKit : UIView <PKCanvasViewDelegate, RCTBridgeModule>

- (void)drawing:(void(^)(NSDictionary *data))completion;
- (void)setToolPicker;
+ (BOOL)requiresMainQueueSetup;
- (void)setDarkMode;
- (void)setLightMode;
- (void)undo;
- (void)redo;

@end

NS_ASSUME_NONNULL_END
