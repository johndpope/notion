#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef enum MidiMessageType {
    /// <summary>
    /// Represents the control change message type
    /// </summary>
    ControlChange = 0xE6,
    
    /// <summary>
    /// Represents the program change message type
    /// </summary>
    ProgramChange = 0xE5,
    
    /// <summary>
    /// Represents the pitch wheel message type
    /// </summary>
    PitchWheel = 0xEB,
    
    /// <summary>
    /// Represents the data entry message type
    /// </summary>
    DataEntry = 0xEA,
    
    /// <summary>
    /// Represents the adaptive chord voicing (ACV) message type
    /// </summary>
    AdaptiveChordVoicing = 0x8A,
    
    /// <summary>
    /// Represents the note message type
    /// </summary>
    Note = -1,
    
    /// <summary>
    /// Represents an unknown message type
    /// </summary>
    Unknown = -2
    
}MidiMessageType;

@interface JPNoteEvent : NSObject
@property (nonatomic, readwrite, assign) Float64 beat;
@property (nonatomic, readwrite, assign) UInt8 note;
@property (nonatomic, readwrite, assign) UInt8 velocity;
@property (nonatomic, readwrite, assign) Float32 duration;
@property (nonatomic, readwrite, assign) Float64 bar;
@property (nonatomic, readwrite, assign) Float64 bpm;
@property (nonatomic, readwrite, assign) int trackNumer;
@property (nonatomic, readonly) MidiMessageType msgType;
// used for channel targeting in midi engine
@property (nonatomic, readwrite, assign) UInt8 channel;
@property (nonatomic, readwrite, assign) MusicTimeStamp timeStamp;
@property (nonatomic, readwrite, assign) int counterPointType;
@property (nonatomic, readwrite, assign) int targetFilter;
-(void)setMessageType:(int16_t)messageType;
- (NSString *)ascii;
@end


