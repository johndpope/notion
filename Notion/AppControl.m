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
    
    /* load FScript */
    [[NSApp mainMenu] addItem:[[FScriptMenuItem alloc] init]];
    
    
    NSString *testMidiFile = [[NSBundle mainBundle] pathForResource:@"bars - 1 2 3 4" ofType:@"mid"];
    NSAssert(testMidiFile != nil, @"File not found");
    _midiData = [NSData dataWithContentsOfFile:testMidiFile];

    song = [[Song alloc] initWithDocument:testDoc];
    [MIDIUtil readSong:song fromMIDI:_midiData];
    
    
    [song.staffs enumerateObjectsUsingBlock: ^(Staff *s, NSUInteger idx, BOOL *stop) {
        NSLog(@"staff:%@", s);
        [s.measures enumerateObjectsUsingBlock: ^(Measure *m, NSUInteger idx, BOOL *stop) {
            NSLog(@"measure:%@", m);
            [m.notes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[Rest class]]) {
                    NSLog(@"rest class:%@", obj);
                }
                else if ([obj isKindOfClass:[Note class]]) {
                    NSLog(@"Note class:%@", obj);
                }
                else {
                    NSLog(@" class:%@", [obj class]);
                }
            }];
        }];
    }];
}

@end
