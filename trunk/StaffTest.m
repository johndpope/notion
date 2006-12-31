//
//  StaffTest.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/6/06.
//  Copyright (c) 2006 Konstantine Prevas. All rights reserved.
//

#import "StaffTest.h"
#import "Staff.h"
#import "Measure.h"
#import "Note.h"

@implementation StaffTest

- (void) setUp{
	staff = [[Staff alloc] initWithSong:nil];
}

- (void) tearDown{
	[staff release];
}

- (void) testGetClefForMeasureWhenMeasureHasClef{
	Measure *measure = [staff getLastMeasure];
	Clef *clef = [Clef alloc];
	[measure setClef:clef];
	STAssertEqualObjects([staff getClefForMeasure:measure], clef, @"Wrong clef returned.");
	[clef release];
}
- (void) testGetClefForMeasureWhenPreviousMeasureHasClef{
	Measure *firstMeasure = [staff getLastMeasure];
	Measure *secondMeasure = [staff addMeasure];
	Clef *clef = [Clef alloc];
	[firstMeasure setClef:clef];
	STAssertEqualObjects([staff getClefForMeasure:secondMeasure], clef, @"Wrong clef returned.");
	[clef release];
}

- (void) testGetKeySignatureForMeasureWhenMeasureHasKeySignature{
	Measure *measure = [staff getLastMeasure];
	KeySignature *keySig = [KeySignature alloc];
	[measure setKeySignature:keySig];
	STAssertEqualObjects([staff getKeySignatureForMeasure:measure], keySig, @"Wrong key signature returned.");
	[keySig release];
}
- (void) testGetKeySignatureForMeasureWhenPreviousMeasureHasKeySignature{
	Measure *firstMeasure = [staff getLastMeasure];
	Measure *secondMeasure = [staff addMeasure];
	KeySignature *keySig = [KeySignature alloc];
	[firstMeasure setKeySignature:keySig];
	STAssertEqualObjects([staff getKeySignatureForMeasure:secondMeasure], keySig, @"Wrong key signature returned.");
	[keySig release];
}

- (void) testGetEffectiveTimeSignatureForMeasureWhenMeasureHasEffectiveTimeSignature{
	Measure *measure = [staff getLastMeasure];
	TimeSignature *timeSig = [TimeSignature alloc];
	Song *song = [[Song alloc] initWithDocument:nil];
	NSMutableArray *timeSigs = [NSMutableArray array];
	[timeSigs addObject:timeSig];
	[song setTimeSigs:timeSigs];
	[staff setSong:song];
	STAssertEqualObjects([staff getEffectiveTimeSignatureForMeasure:measure], timeSig, @"Wrong time signature returned.");
	[timeSig release];
	[song release];
}
- (void) testGetEffectiveTimeSignatureForMeasureWhenPreviousMeasureHasEffectiveTimeSignature{
	Measure *firstMeasure = [staff getLastMeasure];
	Measure *secondMeasure = [staff addMeasure];
	TimeSignature *timeSig = [TimeSignature alloc];
	Song *song = [[Song alloc] initWithDocument:nil];
	NSMutableArray *timeSigs = [NSMutableArray array];
	[timeSigs addObject:[NSNull null]];
	[timeSigs addObject:timeSig];
	[song setTimeSigs:timeSigs];
	[staff setSong:song];
	STAssertEqualObjects([staff getEffectiveTimeSignatureForMeasure:secondMeasure], timeSig, @"Wrong time signature returned.");
	[timeSig release];
	[song release];
}

- (void) testGetLastMeasure{
	[staff addMeasure];
	[staff addMeasure];
	[staff addMeasure];
	[staff addMeasure];
	Measure *lastMeasure = [staff addMeasure];
	STAssertEqualObjects([staff getLastMeasure], lastMeasure, @"Wrong measure returned.");
}

- (void) testGetMeasureAfter{
	Measure *firstMeasure = [staff getLastMeasure];
	Measure *secondMeasure = [staff addMeasure];
	STAssertEqualObjects([staff getMeasureAfter:firstMeasure createNew:NO], secondMeasure, @"Wrong measure returned.");	
}
- (void) testGetMeasureAfterLastDoesntCreateNewMeasureWhenToldNotTo{
	Measure *firstMeasure = [staff getLastMeasure];
	Measure *secondMeasure = [staff addMeasure];
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures before method call.");
	[staff getMeasureAfter:secondMeasure createNew:NO];
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures after method call.");
}
- (void) testGetMeasureAfterFirstDoesntCreateNewMeasure{
	Measure *firstMeasure = [staff getLastMeasure];
	Measure *secondMeasure = [staff addMeasure];
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures before method call.");
	[staff getMeasureAfter:firstMeasure createNew:YES];
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures after method call.");
}
- (void) testGetMeasureAfterLastCreatesNewMeasure{
	Measure *firstMeasure = [staff getLastMeasure];
	Measure *secondMeasure = [staff addMeasure];
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures before method call.");
	[staff getMeasureAfter:secondMeasure createNew:YES];
	STAssertEquals([[staff getMeasures] count], (unsigned)3, @"Wrong number of measures after method call.");
}

- (void) testGetMeasureBefore{
	Measure *firstMeasure = [staff getLastMeasure];
	Measure *secondMeasure = [staff addMeasure];
	STAssertEquals([staff getMeasureBefore:secondMeasure], firstMeasure, @"Wrong measure returned.");
}
- (void) testGetMeasureBeforeFirstMeasure{
	Measure *firstMeasure = [staff getLastMeasure];
	STAssertNil([staff getMeasureBefore:firstMeasure], @"Some measure before first measure returned.");
}

- (void) testGetMeasureContainingNote{
	Measure *secondMeasure = [staff addMeasure];
	[staff addMeasure];
	Note *note = [[Note alloc] init];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:note]];
	STAssertEqualObjects([staff getMeasureContainingNote:note], secondMeasure, @"Wrong measure returned.");
	[note release];
}

- (void) testCleanEmptyMeasuresCleansEmptyMeasureOffEnd{
	Measure *secondMeasure = [staff addMeasure];
	[staff addMeasure];
	Note *note = [[Note alloc] init];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:note]];
	Measure *thirdMeasure = [staff addMeasure];
	[staff cleanEmptyMeasures];
	STAssertFalse([[staff getMeasures] containsObject:thirdMeasure], @"Empty measure was not cleaned.");
	[note release];
}
- (void) testCleanEmptyMeasuresStopsAtNonemptyMeasure{
	Measure *secondMeasure = [staff addMeasure];
	Measure *thirdMeasure = [staff addMeasure];
	[staff addMeasure];
	Note *note = [[Note alloc] init];
	[thirdMeasure setNotes:[NSMutableArray arrayWithObject:note]];
	[staff cleanEmptyMeasures];
	STAssertTrue([[staff getMeasures] containsObject:thirdMeasure], @"Non-empty measure was cleaned.");
	STAssertTrue([[staff getMeasures] containsObject:secondMeasure], @"Empty measure before non-empty measure was cleaned.");
	[note release];
}
- (void) testCleanEmptyMeasuresLeavesOneEmptyMeasure{
	[staff addMeasure];
	[staff addMeasure];
	[staff cleanEmptyMeasures];
	STAssertEquals([[staff getMeasures] count], (unsigned)1, @"Wrong number of measures left after clean.");
}

- (void) testFindPreviousNoteMatchingInSameMeasure{
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	STAssertEqualObjects([staff findPreviousNoteMatching:secondNote inMeasure:measure], firstNote, @"Wrong note returned.");
	[firstNote release];
	[secondNote release];
}
- (void) testFindPreviousNoteMatchingWithDifferentDuration{
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:YES accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	STAssertEqualObjects([staff findPreviousNoteMatching:secondNote inMeasure:measure], firstNote, @"Wrong note returned.");
	[firstNote release];
	[secondNote release];	
}
- (void) testFindPreviousNoteMatchingInPreviousMeasure{
	Measure *firstMeasure = [staff getLastMeasure];
	Measure *secondMeasure = [staff addMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:secondNote]];
	[firstMeasure setNotes:[NSMutableArray arrayWithObject:firstNote]];
	STAssertEqualObjects([staff findPreviousNoteMatching:secondNote inMeasure:secondMeasure], firstNote, @"Wrong note returned.");
	[firstNote release];
	[secondNote release];
}
- (void) testFindPreviousNoteMatchingWhenNoSuchNoteExists{
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:1 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	STAssertNil([staff findPreviousNoteMatching:secondNote inMeasure:measure], @"Wrong note returned.");
	[firstNote release];
	[secondNote release];
}
- (void) testFindPreviousNoteMatchingDoesntReturnNonContiguousNote{
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:1 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, nil]];
	STAssertNil([staff findPreviousNoteMatching:thirdNote inMeasure:measure], @"Wrong note returned.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
}

- (void) testNotesBetweenLeftToRightWithinMeasure{
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:1 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *fourthNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, fourthNote, nil]];
	NSArray *between = [staff notesBetweenNote:firstNote andNote:thirdNote];
	STAssertEquals([between count], (unsigned)3, @"Wrong number of notes between notes.");
	STAssertTrue([between containsObject:firstNote], @"First note not between first and third notes.");
	STAssertTrue([between containsObject:secondNote], @"Second note not between first and third notes.");
	STAssertTrue([between containsObject:thirdNote], @"Third note not between first and third notes.");
	STAssertFalse([between containsObject:fourthNote], @"Fourth note between first and third notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
}

- (void) testNotesBetweenRightToLeftWithinMeasure{
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:1 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *fourthNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, fourthNote, nil]];
	NSArray *between = [staff notesBetweenNote:thirdNote andNote:firstNote];
	STAssertEquals([between count], (unsigned)3, @"Wrong number of notes between notes.");
	STAssertTrue([between containsObject:firstNote], @"First note not between first and third notes.");
	STAssertTrue([between containsObject:secondNote], @"Second note not between first and third notes.");
	STAssertTrue([between containsObject:thirdNote], @"Third note not between first and third notes.");
	STAssertFalse([between containsObject:fourthNote], @"Fourth note between first and third notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
}

- (void) testNotesBetweenLeftToRightAcrossMeasures{
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:1 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *fourthNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	Measure *secondMeasure = [staff getMeasureAfter:measure createNew:YES];
	[secondMeasure setNotes:[NSMutableArray arrayWithObjects:thirdNote, fourthNote, nil]];
	NSArray *between = [staff notesBetweenNote:firstNote andNote:thirdNote];
	STAssertEquals([between count], (unsigned)3, @"Wrong number of notes between notes.");
	STAssertTrue([between containsObject:firstNote], @"First note not between first and third notes.");
	STAssertTrue([between containsObject:secondNote], @"Second note not between first and third notes.");
	STAssertTrue([between containsObject:thirdNote], @"Third note not between first and third notes.");
	STAssertFalse([between containsObject:fourthNote], @"Fourth note between first and third notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
}

- (void) testNotesBetweenRightToLeftAcrossMeasures{
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:1 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *fourthNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	Measure *secondMeasure = [staff getMeasureAfter:measure createNew:YES];
	[secondMeasure setNotes:[NSMutableArray arrayWithObjects:thirdNote, fourthNote, nil]];
	NSArray *between = [staff notesBetweenNote:thirdNote andNote:firstNote];
	STAssertEquals([between count], (unsigned)3, @"Wrong number of notes between notes.");
	STAssertTrue([between containsObject:firstNote], @"First note not between first and third notes.");
	STAssertTrue([between containsObject:secondNote], @"Second note not between first and third notes.");
	STAssertTrue([between containsObject:thirdNote], @"Third note not between first and third notes.");
	STAssertFalse([between containsObject:fourthNote], @"Fourth note between first and third notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
}

- (void) testNotesBetweenSingleNote{
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:1 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *fourthNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, fourthNote, nil]];
	NSArray *between = [staff notesBetweenNote:firstNote andNote:firstNote];
	STAssertEquals([between count], (unsigned)1, @"Wrong number of notes between note and itself.");
	STAssertTrue([between containsObject:firstNote], @"First note not between first note and itself.");
	STAssertFalse([between containsObject:secondNote], @"Second note not between first note and itself.");
	STAssertFalse([between containsObject:thirdNote], @"Third note not between first note and itself.");
	STAssertFalse([between containsObject:fourthNote], @"Fourth note between first note and itself.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
}

- (void) testNotesBetweenArrayLeftToRightWithinMeasure{
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:1 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *fourthNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, fourthNote, nil]];
	NSArray *array = [NSArray arrayWithObjects:firstNote, secondNote, nil];
	NSArray *between = [staff notesBetweenNote:array andNote:thirdNote];
	STAssertEquals([between count], (unsigned)3, @"Wrong number of notes between notes.");
	STAssertTrue([between containsObject:firstNote], @"First note not between first and third notes.");
	STAssertTrue([between containsObject:secondNote], @"Second note not between first and third notes.");
	STAssertTrue([between containsObject:thirdNote], @"Third note not between first and third notes.");
	STAssertFalse([between containsObject:fourthNote], @"Fourth note between first and third notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
}

- (void) testNotesBetweenArrayRightToLeftWithinMeasure{
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:1 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *fourthNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, fourthNote, nil]];
	NSArray *array = [NSArray arrayWithObjects:secondNote, thirdNote, nil];
	NSArray *between = [staff notesBetweenNote:array andNote:firstNote];
	STAssertEquals([between count], (unsigned)3, @"Wrong number of notes between notes.");
	STAssertTrue([between containsObject:firstNote], @"First note not between first and third notes.");
	STAssertTrue([between containsObject:secondNote], @"Second note not between first and third notes.");
	STAssertTrue([between containsObject:thirdNote], @"Third note not between first and third notes.");
	STAssertFalse([between containsObject:fourthNote], @"Fourth note between first and third notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
}

- (void) testNotesBetweenArrayLeftToRightAcrossMeasures{
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:1 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *fourthNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	Measure *secondMeasure = [staff getMeasureAfter:measure createNew:YES];
	[secondMeasure setNotes:[NSMutableArray arrayWithObjects:thirdNote, fourthNote, nil]];
	NSArray *array = [NSArray arrayWithObjects:firstNote, secondNote, nil];
	NSArray *between = [staff notesBetweenNote:array andNote:thirdNote];
	STAssertEquals([between count], (unsigned)3, @"Wrong number of notes between notes.");
	STAssertTrue([between containsObject:firstNote], @"First note not between first and third notes.");
	STAssertTrue([between containsObject:secondNote], @"Second note not between first and third notes.");
	STAssertTrue([between containsObject:thirdNote], @"Third note not between first and third notes.");
	STAssertFalse([between containsObject:fourthNote], @"Fourth note between first and third notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
}

- (void) testNotesBetweenArrayRightToLeftAcrossMeasures{
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:1 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *fourthNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	Measure *secondMeasure = [staff getMeasureAfter:measure createNew:YES];
	[secondMeasure setNotes:[NSMutableArray arrayWithObjects:thirdNote, fourthNote, nil]];
	NSArray *array = [NSArray arrayWithObjects:secondNote, thirdNote, nil];
	NSArray *between = [staff notesBetweenNote:array andNote:firstNote];
	STAssertEquals([between count], (unsigned)3, @"Wrong number of notes between notes.");
	STAssertTrue([between containsObject:firstNote], @"First note not between first and third notes.");
	STAssertTrue([between containsObject:secondNote], @"Second note not between first and third notes.");
	STAssertTrue([between containsObject:thirdNote], @"Third note not between first and third notes.");
	STAssertFalse([between containsObject:fourthNote], @"Fourth note between first and third notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
}

// ----- undo/redo tests -----

- (void)setUpUndoTest{
	doc = [[MusicDocument alloc] init];
	mgr = [[NSUndoManager alloc] init];
	[doc setUndoManager:mgr];
	song = [[Song alloc] initWithDocument:doc];
	staff = [[song staffs] lastObject];
	measure = [staff getLastMeasure];
}

- (void)tearDownUndoTest{
	[song release];
	[mgr release];
	[doc release];	
}

- (void)testUndoRedoToggleClef{
	[self setUpUndoTest];
	Measure *secondMeasure = [staff addMeasure];
	Measure *thirdMeasure = [staff addMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:firstNote atIndex:-0.5 tieToPrev:NO];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[secondMeasure addNote:secondNote atIndex:-0.5 tieToPrev:NO];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[thirdMeasure addNote:thirdNote atIndex:-0.5 tieToPrev:NO];
	[mgr endUndoGrouping];
	int origPitch = [secondNote getPitch];
	int origOctave = [secondNote getOctave];
	[mgr beginUndoGrouping];
	[staff toggleClefAtMeasure:secondMeasure];
	int postPitch = [secondNote getPitch];
	int postOctave = [secondNote getOctave];
	[mgr undo];
	STAssertNil([secondMeasure getClef], @"Failed to undo toggling clef.");
	STAssertEquals([secondNote getPitch], origPitch, @"Note in toggled measure not de-transposed after undoing clef toggle - wrong pitch.");
	STAssertEquals([thirdNote getPitch], origPitch, @"Note in following measure not de-transposed after undoing clef toggle - wrong pitch.");
	STAssertEquals([secondNote getOctave], origOctave, @"Note in toggled measure not de-transposed after undoing clef toggle - wrong octave.");
	STAssertEquals([thirdNote getOctave], origOctave, @"Note in following measure not de-transposed after undoing clef toggle - wrong octave.");
	[mgr redo];
	STAssertNotNil([secondMeasure getClef], @"Failed to redo toggling clef.");
	STAssertEquals([secondNote getPitch], postPitch, @"Note in toggled measure not re-transposed after redoing clef toggle - wrong pitch.");
	STAssertEquals([thirdNote getPitch], postPitch, @"Note in following measure not re-transposed after redoing clef toggle - wrong pitch.");
	STAssertEquals([secondNote getOctave], postOctave, @"Note in toggled measure not re-transposed after redoing clef toggle - wrong octave.");
	STAssertEquals([thirdNote getOctave], postOctave, @"Note in following measure not re-transposed after redoing clef toggle - wrong octave.");
	[firstNote release];
	[secondNote release];
	[self tearDownUndoTest];
}

@end
