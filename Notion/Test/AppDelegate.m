//
//  AppDelegate.m
//  Test
//
//  Created by John Pope on 16/04/2015.
//
//

#import "AppDelegate.h"
#import "MIDIUtil.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
        [MIDIUtil readStylesFromFile];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
