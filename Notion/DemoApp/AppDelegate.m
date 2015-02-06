//
//  AppDelegate.m
//  Notion IOS Demo
//
//  Created by John Pope on 19/01/2015.
//
//

#import "AppDelegate.h"
#import "SNFactory.h"
#import "MIDIUtil.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIViewController *vc  = [[UIViewController alloc] init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    [MIDIUtil readStylesFromFile];
    
    //
    //    NSString *testMidiFile = [[NSBundle mainBundle] pathForResource:@"bars - 1 2 3 4" ofType:@"mid"];
    //    NSAssert(testMidiFile != nil, @"File not found");
    //    NSData *_midiData = [NSData dataWithContentsOfFile:testMidiFile];
    //
    //
    //    Song *song = [[Song alloc] initWithDocument:nil];
    //    [MIDIUtil readSong:song fromMIDI:_midiData];
    //
    //
    //    [song.staffs enumerateObjectsUsingBlock: ^(Staff *s, NSUInteger idx, BOOL *stop) {
    //        NSLog(@"staff:%@", s);
    //        [s.measures enumerateObjectsUsingBlock: ^(Measure *m, NSUInteger idx, BOOL *stop) {
    //            NSLog(@"measure note count:%lu", (unsigned long)[m notes].count);
    //            [m.notes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
    //                if ([obj isKindOfClass:[Rest class]]) {
    //                    NSLog(@"rest :%d", [(Rest *)obj getDuration]);
    //                }
    //                else if ([obj isKindOfClass:[Note class]]) {
    //                    NSLog(@"note :%d", [(Note *) obj getDuration]);
    //                    NSLog(@"note :%d", [(Note *) obj getPitchLetter]);
    //                }
    //                else {
    //                    NSLog(@" class:%@", [obj class]);
    //                }
    //            }];
    //        }];
    //    }];
    
    
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Split view

@end
