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
	Song *song = [[Song alloc] init];
	NSMutableArray *timeSigs = [NSMutableArray array];
	[timeSigs addObject:timeSig];
	[song setTimeSigs:timeSigs];
	[staff setSong:song];
	STAssertEqualObjects([staff getEffectiveTimeSignatureForMeasure:measure], timeSig, @"Wrong time signature returned.");
	[timeSig release];
	[timeSigs release];
	[song release];
}
- (void) testGetEffectiveTimeSignatureForMeasureWhenPreviousMeasureHasEffectiveTimeSignature{
	Measure *firstMeasure = [staff getLastMeasure];
	Measure *secondMeasure = [staff addMeasure];
	TimeSignature *timeSig = [TimeSignature alloc];
	Song *song = [[Song alloc] init];
	NSMutableArray *timeSigs = [NSMutableArray array];
	[timeSigs addObject:[NSNull null]];
	[timeSigs addObject:timeSig];
	[song setTimeSigs:timeSigs];
	[staff setSong:song];
	STAssertEqualObjects([staff getEffectiveTimeSignatureForMeasure:secondMeasure], timeSig, @"Wrong time signature returned.");
	[timeSig release];
	[timeSigs release];
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
	STAssertEqualObjects([staff getMeasureAfter:firstMeasure], secondMeasure, @"Wrong measure returned.");	
}
- (void) testGetMeasureAfterDoesntCreateNewMeasure{
	Measure *firstMeasure = [staff getLastMeasure];
	Measure *secondMeasure = [staff addMeasure];
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures before method call.");
	[staff getMeasureAfter:firstMeasure];
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures after method call.");
}
- (void) testGetMeasureAfterLastCreatesNewMeasure{
	Measure *firstMeasure = [staff getLastMeasure];
	Measure *secondMeasure = [staff addMeasure];
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures before method call.");
	[staff getMeasureAfter:secondMeasure];
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
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	STAssertEqualObjects([staff findPreviousNoteMatching:secondNote inMeasure:measure], firstNote, @"Wrong note returned.");
	[firstNote release];
	[secondNote release];
}
- (void) testFindPreviousNoteMatchingInPreviousMeasure{
	Measure *firstMeasure = [staff getLastMeasure];
	Measure *secondMeasure = [staff addMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	[firstMeasure setNotes:[NSMutableArray arrayWithObject:firstNote]];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:secondNote]];
	STAssertEqualObjects([staff findPreviousNoteMatching:secondNote inMeasure:secondMeasure], firstNote, @"Wrong note returned.");
	[firstNote release];
	[secondNote release];
}
- (void) testFindPreviousNoteMatchingWhenNoSuchNoteExists{
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	Note *secondNote = [[Note alloc] initWithPitch:1 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	STAssertNil([staff findPreviousNoteMatching:secondNote inMeasure:measure], @"Wrong note returned.");
	[firstNote release];
	[secondNote release];
}
- (void) testFindPreviousNoteMatchingDoesntReturnNonContiguousNote{
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	Note *secondNote = [[Note alloc] initWithPitch:1 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, nil]];
	STAssertNil([staff findPreviousNoteMatching:thirdNote inMeasure:measure], @"Wrong note returned.");
	[firstNote release];
	[secondNote release];
}

@end
