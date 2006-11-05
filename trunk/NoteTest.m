//
//  NoteTest.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/17/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "NoteTest.h"
#import "Note.h"
#import "Staff.h"
#import "Measure.h"

@implementation NoteTest

- (void)setUp{
	note = [[Note alloc] initWithPitch:4 octave:3 duration:2 dotted:YES accidental:SHARP onStaff:nil];
}
- (void)tearDown{
	[note release];
}

- (void) testGetEffectiveDuration{
	STAssertEquals([note getEffectiveDuration], (float)2.25, @"Wrong duration returned for note.");
}

- (void) testBasicTryToFill{
	[note tryToFill:1.5];
	STAssertEquals([note getEffectiveDuration], (float)1.5, @"Wrong duration when trying to fill.");
}

- (void) testComplexTryToFill{
	[note tryToFill:0.793847];
	STAssertEquals([note getEffectiveDuration], (float)0.75, @"Wrong duration when trying to fill.");
}

- (void) testSubtractDurationReturningSingleNote{
	NSArray *array = [note subtractDuration:0.75];
	STAssertEquals([array count], (unsigned)1, @"Wrong number of notes returned after subtracting duration.");
	STAssertEquals([[array objectAtIndex:0] getEffectiveDuration], (float)1.5, @"Wrong duration left after subtracting duration.");
	STAssertEquals([note getEffectiveDuration], (float)2.25, @"Original note object modified during subtract duration.");
}

- (void) testSubtractDurationReturningMultipleNotes{
	NSArray *array = [note subtractDuration:0.375];
	STAssertEquals([array count], (unsigned)2, @"Wrong number of notes returned after subtracting duration.");
	STAssertEquals([[array objectAtIndex:0] getEffectiveDuration] + [[array objectAtIndex:1] getEffectiveDuration],
				   (float)1.875, @"Wrong duration left after subtracting duration.");
	STAssertEquals([note getEffectiveDuration], (float)2.25, @"Original note object modified during subtract duration.");
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

@end
