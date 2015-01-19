#import <Cocoa/Cocoa.h>


@class MusicDocument;
@interface AppControl : NSObject {
    MusicDocument *testDoc;
    Song *song;
    NSData *_midiData;
}

@property MusicDocument *testDoc;

+ (AppControl *)cachedAppControl;

@end
