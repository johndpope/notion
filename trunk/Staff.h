//
//  Staff.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/7/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Clef;
@class KeySignature;
@class TimeSignature;
@class Measure;
@class NoteBase;
@class Note;
@class Chord;
@class Song;
@class StaffVerticalRulerComponent;
#import <AudioToolbox/AudioToolbox.h>

@interface Staff : NSObject <NSCoding> {
	NSMutableArray *measures;
	Song *song;
	int channel;
	IBOutlet StaffVerticalRulerComponent *rulerView;
	IBOutlet NSPopUpButton *channelButton;
	IBOutlet NSButton *muteButton;
	IBOutlet NSButton *soloButton;
}

- (id)initWithSong:(Song *)_song;

- (void)setSong:(Song *)_song;
- (Song *)getSong;

- (NSMutableArray *)getMeasures;
- (void)setMeasures:(NSMutableArray *)_measures;

- (StaffVerticalRulerComponent *)rulerView;
- (IBAction)setChannel:(id)sender;
- (IBAction)deleteSelf:(id)sender;

- (Clef *)getClefForMeasure:(Measure *)measure;
- (KeySignature *)getKeySignatureForMeasure:(Measure *)measure;
- (TimeSignature *)getTimeSignatureForMeasure:(Measure *)measure;
- (TimeSignature *)getEffectiveTimeSignatureForMeasure:(Measure *)measure;

- (Measure *)getLastMeasure;
- (Measure *)getMeasureAtIndex:(unsigned)index;
- (Measure *)getMeasureAfter:(Measure *)measure createNew:(BOOL)createNew;
- (Measure *)getMeasureBefore:(Measure *)measure;
- (void)cleanEmptyMeasures;

- (Measure *)getMeasureContainingNote:(NoteBase *)note;
- (Chord *)getChordContainingNote:(NoteBase *)note;

- (Note *)findPreviousNoteMatching:(Note *)source inMeasure:(Measure *)measure;
- (NoteBase *)noteBefore:(NoteBase *)note;
- (NoteBase *)noteAfter:(NoteBase *)note;

- (NSArray *)notesBetweenNote:(id)note1 andNote:(NoteBase *)note2;

- (void)cleanPanels;

- (BOOL)isDrums;

- (void)toggleClefAtMeasure:(Measure *)measure;
- (void)timeSigChangedAtMeasure:(Measure *)measure top:(int)top bottom:(int)bottom;
- (void)timeSigDeletedAtMeasure:(Measure *)measure;

- (IBAction)soloPressed:(id)sender;
- (void)muteSoloEnabled:(BOOL)enabled;

- (BOOL)isMute;
- (BOOL)isSolo;

- (float)addTrackToMIDISequence:(MusicSequence *)musicSequence;

- (Class)getViewClass;
- (Class)getControllerClass;

@end
