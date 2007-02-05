//
//  ChordDrawTest.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 10/8/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "ChordDrawTest.h"
#import "ChordDraw.h"
#import "Chord.h"
#import "Note.h"
#import "Staff.h"
#import "Measure.h"

extern int enableMIDI;

@implementation ChordDrawTest

- (void)setUp{
	enableMIDI = 0;
	Song *song = [[[Song alloc] initWithDocument:nil] autorelease];
	staff = [[Staff alloc] initWithSong:song];
	measure = [staff getLastMeasure];
}

- (void)tearDown{
	[staff release];
}

- (void)testTopNoteOfChordIsOffset{
	Note *firstNote = [[Note alloc] initWithPitch:3 octave:3 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:4 octave:3 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Chord *chord = [[Chord alloc] initWithStaff:staff withNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	[measure addNote:chord atIndex:-0.5 tieToPrev:NO];
	STAssertFalse([ChordDraw isOffset:firstNote inChord:chord inMeasure:measure], @"Bottom note should not be offset.");
	STAssertTrue([ChordDraw isOffset:secondNote inChord:chord inMeasure:measure], @"Top note should be offset.");
	[firstNote release];
	[secondNote release];
	[chord release];
}

- (void)testTopNoteOfChordSpanningOctaveIsOffset{
	Note *firstNote = [[Note alloc] initWithPitch:6 octave:2 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:3 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Chord *chord = [[Chord alloc] initWithStaff:staff withNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	[measure addNote:chord atIndex:-0.5 tieToPrev:NO];
	STAssertFalse([ChordDraw isOffset:firstNote inChord:chord inMeasure:measure], @"Bottom note should not be offset.");
	STAssertTrue([ChordDraw isOffset:secondNote inChord:chord inMeasure:measure], @"Top note should be offset.");
	[firstNote release];
	[secondNote release];
	[chord release];
}

- (void)testBottomNoteOfDownwardStemChordIsOffset{
	Note *firstNote = [[Note alloc] initWithPitch:3 octave:5 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:4 octave:5 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Chord *chord = [[Chord alloc] initWithStaff:staff withNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	[measure addNote:chord atIndex:-0.5 tieToPrev:NO];
	STAssertTrue([ChordDraw isOffset:firstNote inChord:chord inMeasure:measure], @"Bottom note should be offset.");
	STAssertFalse([ChordDraw isOffset:secondNote inChord:chord inMeasure:measure], @"Top note should not be offset.");
	[firstNote release];
	[secondNote release];
	[chord release];
}

- (void)testTopNoteOfDownwardStemChordSpanningOctaveIsOffset{
	Note *firstNote = [[Note alloc] initWithPitch:6 octave:5 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:6 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Chord *chord = [[Chord alloc] initWithStaff:staff withNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	[measure addNote:chord atIndex:-0.5 tieToPrev:NO];
	STAssertTrue([ChordDraw isOffset:firstNote inChord:chord inMeasure:measure], @"Bottom note should be offset.");
	STAssertFalse([ChordDraw isOffset:secondNote inChord:chord inMeasure:measure], @"Top note should not be offset.");
	[firstNote release];
	[secondNote release];
	[chord release];
}

- (void)testNonConsecutiveNotesAreNotOffset{
	Note *firstNote = [[Note alloc] initWithPitch:2 octave:3 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:4 octave:3 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Chord *chord = [[Chord alloc] initWithStaff:staff withNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	[measure addNote:chord atIndex:-0.5 tieToPrev:NO];
	STAssertFalse([ChordDraw isOffset:firstNote inChord:chord inMeasure:measure], @"Bottom note should not be offset.");
	STAssertFalse([ChordDraw isOffset:secondNote inChord:chord inMeasure:measure], @"Top note should not be offset.");
	[firstNote release];
	[secondNote release];
	[chord release];	
}

- (void)testNonConsecutiveDownwardStemNotesAreNotOffset{
	Note *firstNote = [[Note alloc] initWithPitch:2 octave:5 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:4 octave:5 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Chord *chord = [[Chord alloc] initWithStaff:staff withNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	[measure addNote:chord atIndex:-0.5 tieToPrev:NO];
	STAssertFalse([ChordDraw isOffset:firstNote inChord:chord inMeasure:measure], @"Bottom note should not be offset.");
	STAssertFalse([ChordDraw isOffset:secondNote inChord:chord inMeasure:measure], @"Top note should not be offset.");
	[firstNote release];
	[secondNote release];
	[chord release];	
}

@end
