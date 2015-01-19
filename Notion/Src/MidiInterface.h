#import <Cocoa/Cocoa.h>

// some MIDI constants:
enum {
    kMidiMessage_ControlChange      = 0xB,
    kMidiMessage_ProgramChange      = 0xC,
    kMidiMessage_BankMSBControl     = 0,
    kMidiMessage_BankLSBControl     = 32,
    kMidiMessage_NoteOn             = 0x9
};


@interface MidiInterface : NSObject {
}

+ (void)startAudio;
+ (void)stopAudio;

+ (void)playNoteGroup:(NSSet *)noteGroup;

@end
