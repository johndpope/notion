#import "AppControl.h"

#import <FScript/FScript.h>
#import "MIDIUtil.h"

static AppControl *cachedAppControl;

@implementation AppControl

@synthesize testDoc;

+ (AppControl *)cachedAppControl {
    return cachedAppControl;
}

- (void)awakeFromNib {
    cachedAppControl = self;
    
    loops = [[NSMutableArray alloc]init];
    
    /* load FScript */
    [[NSApp mainMenu] addItem:[[FScriptMenuItem alloc] init]];
    
    
    db = [[NSMutableDictionary alloc]init];
    [self loadMidis];
}

- (void)loadMidis {
    NSArray *extensions = @[@"mid"];
    NSArray *paths = nil;
    
    int x = 0;
    for (NSString *extension in extensions) {
        paths = [[NSBundle mainBundle] pathsForResourcesOfType:extension inDirectory:nil];
        
        for (NSString *path in paths) {
            NSLog(@"loading:%@", path);
            NSData *_midiData = [[NSFileManager defaultManager] contentsAtPath:path];
            
            song = [[Song alloc] initWithDocument:nil];
            [MIDIUtil readSong:song fromMIDI:_midiData];
            
            [song.staffs enumerateObjectsUsingBlock: ^(Staff *s, NSUInteger idx, BOOL *stop) {
                NSLog(@"staff:%@", s);
                [s.measures enumerateObjectsUsingBlock: ^(Measure *m, NSUInteger idx, BOOL *stop) {
                    NSLog(@"measure note count:%lu", (unsigned long)[m notes].count);
                    [m.notes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([obj isKindOfClass:[Rest class]]) {
                            NSLog(@"rest :%d", [(Rest *)obj getDuration]);
                        }
                        else if ([obj isKindOfClass:[Note class]]) {
                            NSLog(@"note :%d", [(Note *) obj getDuration]);
                            NSLog(@"note :%d", [(Note *) obj getPitchLetter]);
                        }
                        else if ([obj isKindOfClass:[Chord class]]) {
                            NSLog(@" chord:%@", (Chord *)[obj getNotes]);
                        }
                        else {
                            NSLog(@" obj:%@", [obj class]);
                        }
                    }];
                }];
            }];
        }
    }
}

@end
