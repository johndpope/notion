//
//  NoteTest.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/17/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "NoteTest.h"
#import "Note.h"
#import "NoteBase.h"
#import "Staff.h"
#import "Measure.h"
#include "TestUtil.h"

extern int enableMIDI;

@implementation NoteTest

- (void)setUp{
	enableMIDI = 0;
	note = [[Note alloc] initWithPitch:4 octave:3 duration:2 dotted:YES accidental:SHARP onStaff:nil];
}
- (void)tearDown{
	[note release];
}

- (void) testGetEffectiveDuration{
	STAssertEquals([note getEffectiveDuration], effDuration(2, YES), @"Wrong duration returned for note.");
}

- (void) testBasicTryToFill{
	[note tryToFill:effDuration(2, NO)];
	STAssertEquals([note getEffectiveDuration], effDuration(2, NO), @"Wrong duration when trying to fill.");
}

- (void) testComplexTryToFill{
	[note tryToFill:(effDuration(4, NO) + effDuration(32, YES))];
	STAssertEquals([note getEffectiveDuration], effDuration(4, NO), @"Wrong duration when trying to fill.");
}

- (void) testSubtractDurationReturningSingleNote{
	NSArray *array = [note subtractDuration:effDuration(4, NO)];
	STAssertEquals([array count], (unsigned)1, @"Wrong number of notes returned after subtracting duration.");
	STAssertEquals([[array objectAtIndex:0] getEffectiveDuration], effDuration(2, NO), @"Wrong duration left after subtracting duration.");
	STAssertEquals([note getEffectiveDuration], effDuration(2, YES), @"Original note object modified during subtract duration.");
}

- (void) testSubtractDurationReturningMultipleNotes{
	NSArray *array = [note subtractDuration:effDuration(8, NO)];
	STAssertEquals([array count], (unsigned)2, @"Wrong number of notes returned after subtracting duration.");
	STAssertEquals([[array objectAtIndex:0] getEffectiveDuration] + [[array objectAtIndex:1] getEffectiveDuration],
				   effDuration(2, NO) + effDuration(8, NO), @"Wrong duration left after subtracting duration.");
	STAssertEquals([note getEffectiveDuration], effDuration(2, YES), @"Original note object modified during subtract duration.");
	STAssertEqualObjects([[array objectAtIndex:0] getTieTo], [array objectAtIndex:1], @"Notes returned from subtracting duration not tied together.");
}

- (void) testIsTriplet{
	STAssertFalse([note isTriplet], @"Non-triplet note pretending to be triplet.");
	Note *secondNote = [[Note alloc] initWithPitch:4 octave:3 duration:6 dotted:NO accidental:NO_ACC onStaff:nil];
	STAssertTrue([secondNote isTriplet], @"Triplet note pretending not to be triplet.");
	[secondNote release];
}

- (void) testNotesInSimpleTripletArePartOfFullTriplet{
	Staff *staff = [[Staff alloc] initWithSong:nil];
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, nil]];
	STAssertTrue([firstNote isPartOfFullTriplet], @"Simple triplet note not part of triplet.");
	STAssertTrue([secondNote isPartOfFullTriplet], @"Simple triplet note not part of triplet.");
	STAssertTrue([thirdNote isPartOfFullTriplet], @"Simple triplet note not part of triplet.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[staff release];
}

- (void) testGetContainingTripletOnSimpleTriplet{
	Staff *staff = [[Staff alloc] initWithSong:nil];
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, nil]];
	NSArray *triplet = [firstNote getContainingTriplet];
	STAssertTrue([triplet containsObject:firstNote], @"First note's containing triplet doesn't include first note.");
	STAssertTrue([triplet containsObject:secondNote], @"First note's containing triplet doesn't include second note.");
	STAssertTrue([triplet containsObject:thirdNote], @"First note's containing triplet doesn't include third note.");
	triplet = [secondNote getContainingTriplet];
	STAssertTrue([triplet containsObject:firstNote], @"Second note's containing triplet doesn't include first note.");
	STAssertTrue([triplet containsObject:secondNote], @"Second note's containing triplet doesn't include second note.");
	STAssertTrue([triplet containsObject:thirdNote], @"Second note's containing triplet doesn't include third note.");
	triplet = [thirdNote getContainingTriplet];
	STAssertTrue([triplet containsObject:firstNote], @"Third note's containing triplet doesn't include first note.");
	STAssertTrue([triplet containsObject:secondNote], @"Third note's containing triplet doesn't include second note.");
	STAssertTrue([triplet containsObject:thirdNote], @"Third note's containing triplet doesn't include third note.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[staff release];
}

- (void) testNotesInComplexTripletArePartOfFullTriplet{
	Staff *staff = [[Staff alloc] initWithSong:nil];
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:12 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:12 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:3 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, nil]];
	STAssertTrue([firstNote isPartOfFullTriplet], @"Complex triplet note not part of triplet.");
	STAssertTrue([secondNote isPartOfFullTriplet], @"Complex triplet note not part of triplet.");
	STAssertTrue([thirdNote isPartOfFullTriplet], @"Complex triplet note not part of triplet.");	
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[staff release];
}

- (void) testGetContainingTripletOnComplexTriplet{
	Staff *staff = [[Staff alloc] initWithSong:nil];
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:12 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:12 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:3 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, nil]];
	NSArray *triplet = [firstNote getContainingTriplet];
	STAssertTrue([triplet containsObject:firstNote], @"First note's containing triplet doesn't include first note.");
	STAssertTrue([triplet containsObject:secondNote], @"First note's containing triplet doesn't include second note.");
	STAssertTrue([triplet containsObject:thirdNote], @"First note's containing triplet doesn't include third note.");
	triplet = [secondNote getContainingTriplet];
	STAssertTrue([triplet containsObject:firstNote], @"Second note's containing triplet doesn't include first note.");
	STAssertTrue([triplet containsObject:secondNote], @"Second note's containing triplet doesn't include second note.");
	STAssertTrue([triplet containsObject:thirdNote], @"Second note's containing triplet doesn't include third note.");
	triplet = [thirdNote getContainingTriplet];
	STAssertTrue([triplet containsObject:firstNote], @"Third note's containing triplet doesn't include first note.");
	STAssertTrue([triplet containsObject:secondNote], @"Third note's containing triplet doesn't include second note.");
	STAssertTrue([triplet containsObject:thirdNote], @"Third note's containing triplet doesn't include third note.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[staff release];
}

- (void) testGetContainingTripletOnAnotherComplexTriplet{
	Staff *staff = [[Staff alloc] initWithSong:nil];
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:12 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:12 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *fourthNote = [[Note alloc] initWithPitch:0 octave:0 duration:12 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *fifthNote = [[Note alloc] initWithPitch:0 octave:0 duration:12 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, fourthNote, fifthNote, nil]];
	NSArray *triplet = [firstNote getContainingTriplet];
	STAssertTrue([triplet containsObject:firstNote], @"First note's containing triplet doesn't include first note.");
	STAssertTrue([triplet containsObject:secondNote], @"First note's containing triplet doesn't include second note.");
	STAssertTrue([triplet containsObject:thirdNote], @"First note's containing triplet doesn't include third note.");
	STAssertTrue([triplet containsObject:fourthNote], @"First note's containing triplet doesn't include fourth note.");
	STAssertTrue([triplet containsObject:fifthNote], @"First note's containing triplet doesn't include fifth note.");
	triplet = [secondNote getContainingTriplet];
	STAssertTrue([triplet containsObject:firstNote], @"Second note's containing triplet doesn't include first note.");
	STAssertTrue([triplet containsObject:secondNote], @"Second note's containing triplet doesn't include second note.");
	STAssertTrue([triplet containsObject:thirdNote], @"Second note's containing triplet doesn't include third note.");
	STAssertTrue([triplet containsObject:fourthNote], @"Second note's containing triplet doesn't include fourth note.");
	STAssertTrue([triplet containsObject:fifthNote], @"Second note's containing triplet doesn't include fifth note.");
	triplet = [thirdNote getContainingTriplet];
	STAssertTrue([triplet containsObject:firstNote], @"Third note's containing triplet doesn't include first note.");
	STAssertTrue([triplet containsObject:secondNote], @"Third note's containing triplet doesn't include second note.");
	STAssertTrue([triplet containsObject:thirdNote], @"Third note's containing triplet doesn't include third note.");
	STAssertTrue([triplet containsObject:fourthNote], @"Third note's containing triplet doesn't include fourth note.");
	STAssertTrue([triplet containsObject:fifthNote], @"Third note's containing triplet doesn't include fifth note.");
	triplet = [fourthNote getContainingTriplet];
	STAssertTrue([triplet containsObject:firstNote], @"Fourth note's containing triplet doesn't include first note.");
	STAssertTrue([triplet containsObject:secondNote], @"Fourth note's containing triplet doesn't include second note.");
	STAssertTrue([triplet containsObject:thirdNote], @"Fourth note's containing triplet doesn't include third note.");
	STAssertTrue([triplet containsObject:fourthNote], @"Fourth note's containing triplet doesn't include fourth note.");
	STAssertTrue([triplet containsObject:fifthNote], @"Fourth note's containing triplet doesn't include fifth note.");
	triplet = [fifthNote getContainingTriplet];
	STAssertTrue([triplet containsObject:firstNote], @"Fifth note's containing triplet doesn't include first note.");
	STAssertTrue([triplet containsObject:secondNote], @"Fifth note's containing triplet doesn't include second note.");
	STAssertTrue([triplet containsObject:thirdNote], @"Fifth note's containing triplet doesn't include third note.");
	STAssertTrue([triplet containsObject:fourthNote], @"Fifth note's containing triplet doesn't include fourth note.");
	STAssertTrue([triplet containsObject:fifthNote], @"Fifth note's containing triplet doesn't include fifth note.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
	[fifthNote release];
	[staff release];
}

- (void) testIsolatedTripletNoteIsNotPartOfFullTriplet{
	Staff *staff = [[Staff alloc] initWithSong:nil];
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	STAssertFalse([firstNote isPartOfFullTriplet], @"Isolated triplet note pretending to be part of triplet.");
	[firstNote release];
	[secondNote release];
	[staff release];
}

- (void) testGetContainingTripletOnIsolatedTripletNote{
	Staff *staff = [[Staff alloc] initWithSong:nil];
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	STAssertNil([firstNote getContainingTriplet], @"Isolated triplet note returns containing triplet.");
	[firstNote release];
	[secondNote release];
	[staff release];
}

- (void) testIsolatedTripletNoteAfterTripletIsNotPartOfFullTriplet{
	Staff *staff = [[Staff alloc] initWithSong:nil];
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *fourthNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];	
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, fourthNote, nil]];
	STAssertFalse([fourthNote isPartOfFullTriplet], @"Isolated triplet note pretending to be part of triplet.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
	[staff release];
}

- (void) testGetContainingTripletOnIsolatedTripletNoteAfterTriplet{
	Staff *staff = [[Staff alloc] initWithSong:nil];
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *fourthNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];	
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, fourthNote, nil]];
	STAssertNil([fourthNote getContainingTriplet], @"Isolated triplet note returns containing triplet.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
	[staff release];
}

- (void) testNonTripletNoteIsNotPartOfFullTriplet{
	Staff *staff = [[Staff alloc] initWithSong:nil];
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, nil]];
	STAssertFalse([thirdNote isPartOfFullTriplet], @"Non-triplet note pretending to be part of triplet.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[staff release];
}

- (void) testGetContainingTripletOnNonTripletNote{
	Staff *staff = [[Staff alloc] initWithSong:nil];
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:6 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, nil]];
	STAssertNil([thirdNote getContainingTriplet], @"Non-triplet note returns containing triplet.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[staff release];
}

- (void)testTransposeNoAccidental {
	KeySignature *oldSig = [KeySignature getSignatureWithSharps:0 minor:NO];
	KeySignature *newSig = [KeySignature getSignatureWithSharps:1 minor:NO];
	Note *note = [[Note alloc] initWithPitch:4 octave:3 duration:4 dotted:NO accidental:NO_ACC onStaff:nil];
	int oldPitch = [note getEffectivePitchWithKeySignature:oldSig priorAccidentals:nil];
	[note transposeBy:7 oldSignature:oldSig newSignature:newSig];
	STAssertEquals((int)[note getEffectivePitchWithKeySignature:newSig priorAccidentals:nil], oldPitch + 7, @"Note transposed incorrectly.");
	[note transposeBy:-7 oldSignature:newSig newSignature:oldSig];
	STAssertEquals((int)[note getEffectivePitchWithKeySignature:oldSig priorAccidentals:nil], oldPitch, @"Note transposed incorrectly.");
	[note release];
}

- (void)testTransposeSharp {
	KeySignature *oldSig = [KeySignature getSignatureWithSharps:0 minor:NO];
	KeySignature *newSig = [KeySignature getSignatureWithSharps:1 minor:NO];
	Note *note = [[Note alloc] initWithPitch:4 octave:3 duration:4 dotted:NO accidental:SHARP onStaff:nil];
	int oldPitch = [note getEffectivePitchWithKeySignature:oldSig priorAccidentals:nil];
	[note transposeBy:7 oldSignature:oldSig newSignature:newSig];
	STAssertEquals((int)[note getEffectivePitchWithKeySignature:newSig priorAccidentals:nil], oldPitch + 7, @"Note transposed incorrectly.");
	[note transposeBy:-7 oldSignature:newSig newSignature:oldSig];
	STAssertEquals((int)[note getEffectivePitchWithKeySignature:oldSig priorAccidentals:nil], oldPitch, @"Note transposed incorrectly.");
	[note release];
}

- (void)testTransposeSharpWhenNewKeySigHasSharp {
	KeySignature *oldSig = [KeySignature getSignatureWithSharps:0 minor:NO];
	KeySignature *newSig = [KeySignature getSignatureWithSharps:1 minor:NO];
	Note *note = [[Note alloc] initWithPitch:6 octave:3 duration:4 dotted:NO accidental:SHARP onStaff:nil];
	int oldPitch = [note getEffectivePitchWithKeySignature:oldSig priorAccidentals:nil];
	[note transposeBy:7 oldSignature:oldSig newSignature:newSig];
	STAssertEquals((int)[note getEffectivePitchWithKeySignature:newSig priorAccidentals:nil], oldPitch + 7, @"Note transposed incorrectly.");
	[note transposeBy:-7 oldSignature:newSig newSignature:oldSig];
	STAssertEquals((int)[note getEffectivePitchWithKeySignature:oldSig priorAccidentals:nil], oldPitch, @"Note transposed incorrectly.");
	[note release];
}

- (void)testTransposeSharpWhenNewKeySigHasFlat {
	KeySignature *oldSig = [KeySignature getSignatureWithSharps:0 minor:NO];
	KeySignature *newSig = [KeySignature getSignatureWithFlats:1 minor:NO];
	Note *note = [[Note alloc] initWithPitch:4 octave:3 duration:4 dotted:NO accidental:SHARP onStaff:nil];
	int oldPitch = [note getEffectivePitchWithKeySignature:oldSig priorAccidentals:nil];
	[note transposeBy:5 oldSignature:oldSig newSignature:newSig];
	STAssertEquals((int)[note getEffectivePitchWithKeySignature:newSig priorAccidentals:nil], oldPitch + 5, @"Note transposed incorrectly.");
	[note transposeBy:-5 oldSignature:newSig newSignature:oldSig];
	STAssertEquals((int)[note getEffectivePitchWithKeySignature:oldSig priorAccidentals:nil], oldPitch, @"Note transposed incorrectly.");
	[note release];
}

- (void)testTransposeFlat {
	KeySignature *oldSig = [KeySignature getSignatureWithSharps:0 minor:NO];
	KeySignature *newSig = [KeySignature getSignatureWithSharps:1 minor:NO];
	Note *note = [[Note alloc] initWithPitch:4 octave:3 duration:4 dotted:NO accidental:FLAT onStaff:nil];
	int oldPitch = [note getEffectivePitchWithKeySignature:oldSig priorAccidentals:nil];
	[note transposeBy:7 oldSignature:oldSig newSignature:newSig];
	STAssertEquals((int)[note getEffectivePitchWithKeySignature:newSig priorAccidentals:nil], oldPitch + 7, @"Note transposed incorrectly.");
	[note transposeBy:-7 oldSignature:newSig newSignature:oldSig];
	STAssertEquals((int)[note getEffectivePitchWithKeySignature:oldSig priorAccidentals:nil], oldPitch, @"Note transposed incorrectly.");
	[note release];
}

- (void)testTransposeFlatWhenNewKeySigHasSharp {
	KeySignature *oldSig = [KeySignature getSignatureWithSharps:0 minor:NO];
	KeySignature *newSig = [KeySignature getSignatureWithSharps:1 minor:NO];
	Note *note = [[Note alloc] initWithPitch:6 octave:3 duration:4 dotted:NO accidental:FLAT onStaff:nil];
	int oldPitch = [note getEffectivePitchWithKeySignature:oldSig priorAccidentals:nil];
	[note transposeBy:7 oldSignature:oldSig newSignature:newSig];
	STAssertEquals((int)[note getEffectivePitchWithKeySignature:newSig priorAccidentals:nil], oldPitch + 7, @"Note transposed incorrectly.");
	[note transposeBy:-7 oldSignature:newSig newSignature:oldSig];
	STAssertEquals((int)[note getEffectivePitchWithKeySignature:oldSig priorAccidentals:nil], oldPitch, @"Note transposed incorrectly.");
	[note release];
}

- (void)testTransposeFlatWhenNewKeySigHasFlat {
	KeySignature *oldSig = [KeySignature getSignatureWithSharps:0 minor:NO];
	KeySignature *newSig = [KeySignature getSignatureWithFlats:3 minor:YES];
	Note *note = [[Note alloc] initWithPitch:6 octave:3 duration:4 dotted:NO accidental:FLAT onStaff:nil];
	int oldPitch = [note getEffectivePitchWithKeySignature:oldSig priorAccidentals:nil];
	[note transposeBy:0 oldSignature:oldSig newSignature:newSig];
	STAssertEquals((int)[note getEffectivePitchWithKeySignature:newSig priorAccidentals:nil], oldPitch, @"Note transposed incorrectly.");
	[note transposeBy:0 oldSignature:newSig newSignature:oldSig];
	STAssertEquals((int)[note getEffectivePitchWithKeySignature:oldSig priorAccidentals:nil], oldPitch, @"Note transposed incorrectly.");
	[note release];
}

- (void)testSetPitchBreaksTies {
	Note *note = [[Note alloc] initWithPitch:6 octave:3 duration:4 dotted:NO accidental:NO_ACC onStaff:nil];
	Note *preNote = [[Note alloc] initWithPitch:6 octave:3 duration:4 dotted:NO accidental:NO_ACC onStaff:nil];
	Note *postNote = [[Note alloc] initWithPitch:6 octave:3 duration:4 dotted:NO accidental:NO_ACC onStaff:nil];
	[note tieFrom:preNote];
	[preNote tieTo:note];
	[note tieTo:postNote];
	[preNote tieFrom:note];
	[note setPitch:2 finished:YES];
	STAssertNil([note getTieFrom], @"Changing note pitch failed to break incoming tie.");
	STAssertNil([preNote getTieTo], @"Changing note pitch failed to break incoming tie.");
	STAssertNil([note getTieTo], @"Changing note pitch failed to break outgoing tie.");
	STAssertNil([postNote getTieFrom], @"Changing note pitch failed to break outgoing tie.");
	[note release];
	[preNote release];
	[postNote release];
}

- (void)testSetOctaveBreaksTies {
	Note *note = [[Note alloc] initWithPitch:6 octave:3 duration:4 dotted:NO accidental:NO_ACC onStaff:nil];
	Note *preNote = [[Note alloc] initWithPitch:6 octave:3 duration:4 dotted:NO accidental:NO_ACC onStaff:nil];
	Note *postNote = [[Note alloc] initWithPitch:6 octave:3 duration:4 dotted:NO accidental:NO_ACC onStaff:nil];
	[note tieFrom:preNote];
	[preNote tieTo:note];
	[note tieTo:postNote];
	[preNote tieFrom:note];
	[note setOctave:4 finished:YES];
	STAssertNil([note getTieFrom], @"Changing note pitch failed to break incoming tie.");
	STAssertNil([preNote getTieTo], @"Changing note pitch failed to break incoming tie.");
	STAssertNil([note getTieTo], @"Changing note pitch failed to break outgoing tie.");
	STAssertNil([postNote getTieFrom], @"Changing note pitch failed to break outgoing tie.");
	[note release];
	[preNote release];
	[postNote release];
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

- (void)testUndoRedoSetPitch {
	[self setUpUndoTest];
	Note *note = [[Note alloc] initWithPitch:3 octave:4 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[mgr beginUndoGrouping];
	[note setPitch:6 finished:YES];
	[mgr endUndoGrouping];
	[mgr undo];
	STAssertEquals([note getPitch], 3, @"Failed to undo setting pitch.");
	[mgr redo];
	STAssertEquals([note getPitch], 6, @"Failed to redo setting pitch.");
	[note release];
	[self tearDownUndoTest];
}

- (void)testUndoRedoSetOctave {
	[self setUpUndoTest];
	Note *note = [[Note alloc] initWithPitch:3 octave:4 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[mgr beginUndoGrouping];
	[note setOctave:6 finished:YES];
	[mgr endUndoGrouping];
	[mgr undo];
	STAssertEquals([note getOctave], 4, @"Failed to undo setting octave.");
	[mgr redo];
	STAssertEquals([note getOctave], 6, @"Failed to redo setting octave.");
	[note release];
	[self tearDownUndoTest];
}

- (void)testUndoDoesntAffectTemporarySetPitch {
	[self setUpUndoTest];
	Note *note = [[Note alloc] initWithPitch:3 octave:4 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[mgr beginUndoGrouping];
	[note setPitch:6 finished:NO];
	[mgr endUndoGrouping];
	[mgr undo];
	STAssertEquals([note getPitch], 6, @"Temporary change of pitch undone.");
	[note release];
	[self tearDownUndoTest];
}

- (void)testUndoDoesntAffectTemporarySetOctave {
	[self setUpUndoTest];
	Note *note = [[Note alloc] initWithPitch:3 octave:4 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[mgr beginUndoGrouping];
	[note setOctave:6 finished:NO];
	[mgr endUndoGrouping];
	[mgr undo];
	STAssertEquals([note getOctave], 6, @"Temporary change of octave undone.");
	[note release];
	[self tearDownUndoTest];
}

- (void)testUndoRedoSetPitchWithTemporarySets {
	[self setUpUndoTest];
	Note *note = [[Note alloc] initWithPitch:3 octave:3 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[mgr beginUndoGrouping];
	[note setPitch:4 finished:NO];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[note setPitch:5 finished:NO];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[note setPitch:6 finished:YES];
	[mgr endUndoGrouping];
	[mgr undo];
	STAssertEquals([note getPitch], 3, @"Failed to undo setting pitch.");
	[mgr redo];
	STAssertEquals([note getPitch], 6, @"Failed to redo setting pitch.");
	[note release];
	[self tearDownUndoTest];
}

- (void)testUndoRedoSetOctaveWithTemporarySets {
	[self setUpUndoTest];
	Note *note = [[Note alloc] initWithPitch:3 octave:3 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[mgr beginUndoGrouping];
	[note setOctave:4 finished:NO];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[note setOctave:5 finished:NO];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[note setOctave:6 finished:YES];
	[mgr endUndoGrouping];
	[mgr undo];
	STAssertEquals([note getOctave], 3, @"Failed to undo setting octave.");
	[mgr redo];
	STAssertEquals([note getOctave], 6, @"Failed to redo setting octave.");
	[note release];
	[self tearDownUndoTest];
}

@end
