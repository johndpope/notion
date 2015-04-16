#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "NSData+SnapAdditions.h"
@class Song, SimpleSong;

typedef enum {
    Intro      = 0,
    Original      = 1,
    Variation     = 2,
    Variation2     = 3,
    FillToOriginal             = 4,
    FillToVariation = 5,
    FillToVariation2 = 6,
    Ending = 7
} CurrentPart;

typedef enum {
    Major      = 0,
    Minor      = 1,
    Seventh     = 2,
} ChordType;

@interface InstrumentAddress :NSObject;
-(int)addressForChordType:(ChordType)type;
@property(nonatomic) int16_t major;
@property(nonatomic) int16_t minor;
@property(nonatomic) int16_t seventh;
@property(nonatomic,strong) NSMutableArray *notes;
-(id)initWithMajor:(int)major minor:(int)minor seventh:(int)seventh;
-(BOOL)isAvailableChordType:(ChordType)type;
@end



@interface StylePart : NSObject
@property(nonatomic,strong) InstrumentAddress *address;
@property(nonatomic) CurrentPart part;

@end


@interface MIDIUtil : NSObject {
}
+ (void)saveMIDIForStylePart:(StylePart *)style currentPart:(CurrentPart)part instrument:(int)instrument;

+ (void)readSong:(Song *)song fromMIDI:(NSData *)data;
+ (NSData *)writeSequenceToData:(MusicSequence)seq;
+ (void)processMidiFileWithName:(NSString *)name;
+ (void)readStylesFromFile:(NSData *)data;
+ (int16_t)endian16_readInt16From:(NSData *)data offset:(unsigned int)offset length:(unsigned int)length;
+ (void)readStylesFromFile;
@end
