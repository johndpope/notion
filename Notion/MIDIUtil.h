#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "NSData+SnapAdditions.h"
@class Song, SimpleSong;

@interface MIDIUtil : NSObject {
}

+ (void)parseMidiData:(NSData *)data intoSong:(Song *)song;

+ (void)readSong:(Song *)song fromMIDI:(NSData *)data;
+ (NSData *)writeSequenceToData:(MusicSequence)seq;
+ (void)processMidiFileWithName:(NSString *)name;
+ (void)readStylesFromFile:(NSData *)data;
+ (void)readStylesFromFile;
@end
