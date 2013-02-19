//
//  MotionControlInjector.m
//  MotionControl
//
//  Created by Conrad Kramer on 2/18/13.
//  Copyright (c) 2013 Conrad Kramer. All rights reserved.
//

@interface MotionControlDummyClass : NSObject
@end
@implementation MotionControlDummyClass
@end

OSErr HandleLoadEvent(const AppleEvent *event, AppleEvent *reply, long refcon) {
    NSBundle *mainBundle = [NSBundle mainBundle];
    if (![[mainBundle bundleIdentifier] isEqualToString:@"com.apple.dock"]) return errAEEventNotHandled;
    
    NSBundle *helperBundle = [NSBundle bundleForClass:[MotionControlDummyClass class]];
    
    NSString *motionControlPath = [helperBundle pathForResource:@"MotionControl" ofType:@"bundle"];
    NSBundle *motionControlBundle = [NSBundle bundleWithPath:motionControlPath];
        
    BOOL loaded = [motionControlBundle load];
    
    return loaded ? noErr : -1;
}