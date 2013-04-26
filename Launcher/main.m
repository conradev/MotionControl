//
//  main.m
//  MotionControlLauncher
//
//  Created by Conrad Kramer on 3/6/13.
//  Copyright (c) 2013 Conrad Kramer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[]) {
    NSString *helperPath = [[NSBundle mainBundle] pathForResource:@"MotionControlHelper" ofType:@"osax"];
    NSString *existingHelperPath = [@"/Library/ScriptingAdditions/" stringByAppendingPathComponent:[helperPath lastPathComponent]];

    NSBundle *helperBundle = [NSBundle bundleWithPath:helperPath];
    NSBundle *existingHelperBundle = [NSBundle bundleWithPath:existingHelperPath];
    
    NSBundle *mainBundle = [NSBundle bundleWithPath:[helperBundle pathForResource:@"MotionControl" ofType:@"bundle"]];
    NSBundle *existingMainBundle = [NSBundle bundleWithPath:[existingHelperBundle pathForResource:@"MotionControl" ofType:@"bundle"]];
    
    id (^version)(NSBundle *) = ^(NSBundle *a) { return [[a infoDictionary] objectForKey:(id)kCFBundleVersionKey]; };
    BOOL (^compareVersion)(NSBundle *, NSBundle *) = ^(NSBundle *a, NSBundle *b) { return [version(a) isEqual:version(b)]; };
    if (!compareVersion(helperBundle, existingHelperBundle) || !compareVersion(mainBundle, existingMainBundle)) {
        NSString *command = [NSString stringWithFormat:@"cp -rf %@ %@", helperPath, existingHelperPath];
        NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", command];
        NSAppleScript *installScript = [[NSAppleScript alloc] initWithSource:script];
        
        NSDictionary *error = @{};
        if (![installScript executeAndReturnError:&error]) {
            [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
            NSAlert *errorAlert = [NSAlert alertWithMessageText:@"Install Error" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", [error objectForKey:NSAppleScriptErrorMessage]];
            [errorAlert runModal];
            
            return 0;
        }
    }
    
    NSString *script = @"tell application \"Dock\"\n"
                       @"«event MCTLLoad»\n"
                       @"end tell";
    NSAppleScript *loadScript = [[NSAppleScript alloc] initWithSource:script];
    NSDictionary *error = @{};
    if (![loadScript executeAndReturnError:&error]) {
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
        NSAlert *errorAlert = [NSAlert alertWithMessageText:@"Load Error" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", [error objectForKey:NSAppleScriptErrorMessage]];
        [errorAlert runModal];
    }
    
    return 0;
}
