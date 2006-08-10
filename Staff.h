//
//  Staff.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
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

@interface Staff : NSObject {
	NSMutableArray *measures;
	Song *song;
	int channel;
	IBOutlet StaffVerticalRulerComponent *rulerView;
	IBOutlet NSPopUpButton *channelButton;
}

- (id)initWithSong:(Song *)_song;

- (NSMutableArray *)getMeasures;
- (void)setMeasures:(NSMutableArray *)_measures;

- (StaffVerticalRulerComponent *)rulerView;
- (IBAction)setChannel:(id)sender;
- (IBAction)deleteSelf:(id)sender;

- (Clef *)getClefForMeasure:(Measure *)measure;
- (KeySignature *)getKeySignatureForMeasure:(Measure *)measure;
- (TimeSignature *)getTimeSignatureForMeasure:(Measure *)measure;

- (Measure *)getLastMeasure;
- (Measure *)getMeasureAfter:(Measure *)measure;
- (void)cleanEmptyMeasures;

- (Note *)findPreviousNoteMatching:(Note *)source inMeasure:(Measure *)measure atIndex:(int)index;

- (void)toggleClefAtMeasure:(Measure *)measure;

- (void)addTrackToMIDISequence:(MusicSequence *)musicSequence;

@end
