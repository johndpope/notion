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
@class DrumKit;
@class StaffVerticalRulerComponent;
#import <AudioToolbox/AudioToolbox.h>

@interface Staff : NSObject <NSCoding> {
	NSMutableArray *measures;
	Song *song;
	NSString *name;
	int transposition;
	int channel;
	IBOutlet StaffVerticalRulerComponent *rulerView;
	BOOL mute, solo, canMute;
	DrumKit *drumKit;
	
	MusicTrack musicTrack;
}

- (id)initWithSong:(Song *)_song;

- (void)setSong:(Song *)_song;
- (Song *)getSong;

- (NSString *)name;
- (void)setName:(NSString *)_name;

- (int)transposition;
- (void)setTransposition:(int)_transposition;

- (NSMutableArray *)getMeasures;
- (void)setMeasures:(NSMutableArray *)_measures;

- (StaffVerticalRulerComponent *)rulerView;
- (IBAction)deleteSelf:(id)sender;

- (Clef *)getClefForMeasure:(Measure *)measure;
- (KeySignature *)getKeySignatureForMeasure:(Measure *)measure;
- (TimeSignature *)getTimeSignatureForMeasure:(Measure *)measure;
- (TimeSignature *)getEffectiveTimeSignatureForMeasure:(Measure *)measure;

- (Measure *)getLastMeasure;
- (Measure *)getMeasureAtIndex:(unsigned)index;
- (Measure *)getMeasureAfter:(Measure *)measure createNew:(BOOL)createNew;
- (Measure *)getMeasureBefore:(Measure *)measure;
- (Measure *)getMeasureWithKeySignatureBefore:(Measure *)measure;
- (void)cleanEmptyMeasures;

- (void)transposeFrom:(KeySignature *)oldSig to:(KeySignature *)newSig startingAt:(Measure *)measure;

- (Measure *)getMeasureContainingNote:(NoteBase *)note;
- (Chord *)getChordContainingNote:(NoteBase *)note;

- (Note *)findPreviousNoteMatching:(Note *)source inMeasure:(Measure *)measure;
- (NoteBase *)noteBefore:(NoteBase *)note;
- (NoteBase *)noteAfter:(NoteBase *)note;

- (NSArray *)notesBetweenNote:(id)note1 andNote:(id)note2;

- (void)cleanPanels;

- (BOOL)isDrums;
- (void)setIsDrums:(BOOL)isDrums;
- (DrumKit *)drumKit;
- (IBAction)editDrumKit:(id)sender;

- (void)toggleClefAtMeasure:(Measure *)measure;
- (void)timeSigChangedAtMeasure:(Measure *)measure top:(int)top bottom:(int)bottom;
- (void)timeSigChangedAtMeasure:(Measure *)measure top:(int)top bottom:(int)bottom secondTop:(int)secondTop secondBottom:(int)secondBottom;
- (void)timeSigDeletedAtMeasure:(Measure *)measure;

- (BOOL)canMute;
- (void)setCanMute:(BOOL)enabled;

- (BOOL)mute;
- (BOOL)solo;
- (void)setMute:(BOOL)_mute;
- (void)setSolo:(BOOL)_solo;

- (int)channel;
- (void)setChannel:(int)_channel;

- (float)addTrackToMIDISequence:(MusicSequence *)musicSequence notesToPlay:(id)selection;

- (Class)getViewClass;
- (Class)getControllerClass;

@end
