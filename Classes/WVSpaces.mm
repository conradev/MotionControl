//
//  WVSpaces.m
//  MotionControl
//
//  Created by Conrad Kramer on 2/19/13.
//  Copyright (c) 2013 Conrad Kramer. All rights reserved.
//

#include <objc/message.h>

#import "LeapObjectiveC.h"
#import "WVSpaces.h"

#define MOTION_SCALE_FACTOR 250.0f

@interface WVSpaces (MotionControl)
- (void)initializeLeapController;
@end

LeapController *controller;

static char gestureKey;

#pragma mark - Fluid Gesture Hooks

static void (*fluidGestureStart_orig)(WVSpaces *, SEL, CGSEventRecord);
static void fluidGestureStart(WVSpaces *self, SEL _cmd, CGSEventRecord record) {
    if (objc_getAssociatedObject(self, &gestureKey) == nil) {
        fluidGestureStart_orig(self, _cmd, record);
    }
    
    [self initializeLeapController];
}

static void (*fluidGestureSwipe_orig)(WVSpaces *, SEL, CGSEventRecord, float);
static void fluidGestureSwipe(WVSpaces *self, SEL _cmd, CGSEventRecord record, float progress) {
    if (objc_getAssociatedObject(self, &gestureKey) == nil) {
        fluidGestureSwipe_orig(self, _cmd, record, progress);
    }    
}

static void (*fluidGestureStop_orig)(WVSpaces *, SEL, CGSEventRecord, BOOL, double, BOOL);
static void fluidGestureStop(WVSpaces *self, SEL _cmd, CGSEventRecord record, BOOL canceled, double velocity, BOOL forward) {
    if (objc_getAssociatedObject(self, &gestureKey) == nil) {
        fluidGestureStop_orig(self, _cmd, record, canceled, velocity, forward);
    }
}

#pragma mark - Lifecycle

static void initializeLeapController(WVSpaces *self, SEL _cmd) {    
    if (controller == nil) {
        controller = [[LeapController alloc] init];
        [controller setPolicyFlags:LEAP_POLICY_BACKGROUND_FRAMES];
        [controller addDelegate:self];        
    }
}

#pragma mark - LeapDelegate

static void onConnect(WVSpaces *self, SEL _cmd, LeapController *controller) {
    [controller enableGesture:LEAP_GESTURE_TYPE_SWIPE enable:YES];
}

static void onDisconnect(WVSpaces *self, SEL _cmd, LeapController *controller) {
    NSNumber *gestureId = objc_getAssociatedObject(self, &gestureKey);
    if (gestureId) {
        objc_setAssociatedObject(self, &gestureKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        CGSEventRecord record;
        fluidGestureStop_orig(self, @selector(fluidGestureStop:canceled:velocity:forward:), record, YES, 0.0f, NO);
    }
}

static void onFrame(WVSpaces *self, SEL _cmd, LeapController *controller) {
    LeapFrame *currentFrame = [controller frame:0];
    NSNumber *gestureId = objc_getAssociatedObject(self, &gestureKey);
    CGSEventRecord record;
    
    if (!gestureId && !self.anySwitchingOccuring) {
        NSArray *gestures = [currentFrame gestures:nil];
        NSUInteger index = [gestures indexOfObjectPassingTest:^BOOL(LeapGesture *gesture, NSUInteger idx, BOOL *stop) {
            *stop = (gesture.type == LEAP_GESTURE_TYPE_SWIPE);
            return *stop;
        }];
        LeapSwipeGesture *gesture = (index != NSNotFound) ? [gestures objectAtIndex:index] : nil;

        if (gesture) {
            objc_setAssociatedObject(self, &gestureKey, @([gesture id]), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            fluidGestureStart_orig(self, @selector(fluidGestureStart:), record);
        }
    } else if (gestureId) {
        LeapSwipeGesture *gesture = (LeapSwipeGesture *)[currentFrame gesture:[gestureId intValue]];
        
        if ([gesture isValid]) {
            float progress = ((gesture.position.x - gesture.startPosition.x) /(-1.0f * MOTION_SCALE_FACTOR));
            fluidGestureSwipe_orig(self, @selector(fluidGestureSwipe:progress:), record, progress);
        } else {
            // Find last valid gesture
            gesture = nil;
            unsigned history = 1;
            while (![gesture isValid] && history < 10) {
                gesture = (LeapSwipeGesture *)[[controller frame:history] gesture:[gestureId intValue]];
                history++;
            }
            
            objc_setAssociatedObject(self, &gestureKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            BOOL forward = (-1.0f * gesture.direction.x > 0);
            float velocity = ((gesture.speed * gesture.direction.x) /(-1.0f *  MOTION_SCALE_FACTOR));
            fluidGestureStop_orig(self, @selector(fluidGestureStop:canceled:velocity:forward:), record, NO, velocity, forward);
        }
    }
}

#pragma mark - Constructor

static __attribute__((constructor)) void constructor() {
    Class spacesClass = objc_getClass("WVSpaces");

    // Lifecycle methods
    class_addMethod(spacesClass, @selector(initializeLeapController), (IMP)&initializeLeapController, "v@:");
    
    // Gesture methods
    Method startMethod = class_getInstanceMethod(spacesClass, @selector(fluidGestureStart:));
    fluidGestureStart_orig = (void (*)(WVSpaces *, SEL, CGSEventRecord))method_setImplementation(startMethod, (IMP)&fluidGestureStart);
    Method swipeMethod = class_getInstanceMethod(spacesClass, @selector(fluidGestureSwipe:progress:));
    fluidGestureSwipe_orig = (void (*)(WVSpaces *, SEL, CGSEventRecord, float))method_setImplementation(swipeMethod, (IMP)&fluidGestureSwipe);
    Method stopMethod = class_getInstanceMethod(spacesClass, @selector(fluidGestureStop:canceled:velocity:forward:));
    fluidGestureStop_orig = (void (*)(WVSpaces *, SEL, CGSEventRecord, BOOL, double, BOOL))method_setImplementation(stopMethod, (IMP)&fluidGestureStop);
    
    // LeapDelegate protocol
    const char *typeEncoding = "v@:@";
    class_addMethod(spacesClass, @selector(onConnect:), (IMP)&onConnect, typeEncoding);
    class_addMethod(spacesClass, @selector(onDisconnect:), (IMP)&onDisconnect, typeEncoding);
    class_addMethod(spacesClass, @selector(onFrame:), (IMP)&onFrame, typeEncoding);
    class_addProtocol(spacesClass, @protocol(LeapDelegate));    
}