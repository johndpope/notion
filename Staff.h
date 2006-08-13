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
@class Note;
@class Song;
@class StaffVerticalRulerComponent;
#import <AudioToolbox/AudioToolbox.h>

@interface Staff : NSObject <NSCoding> {
	NSMutableArray *measures;
	Song *song;
	int channel;
	IBOutlet StaffVerticalRulerComponent *rulerView;
	IBOutlet NSPopUpButton *channelButton;
}

- (id)initWithSong:(Song *)_song;

- (void)setSong:(Song *)_song;

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
- (Measure *)getMeasureAfter:(Measure *)measure;
- (Measure *)getMeasureBefore:(Measure *)measure;
- (Measure *)getMeasureContainingNote:(Note *)note;
- (void)cleanEmptyMeasures;

- (Note *)findPreviousNoteMatching:(Note *)source inMeasure:(Measure *)measure;

- (void)cleanPanels;

- (void)toggleClefAtMeasure:(Measure *)measure;
- (void)timeSigChangedAtMeasure:(Measure *)measure top:(int)top bottom:(int)bottom;

- (void)addTrackToMIDISequence:(MusicSequence *)musicSequence;

@end
