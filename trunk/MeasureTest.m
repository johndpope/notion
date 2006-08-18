//
//  MeasureTest.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/8/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "MeasureTest.h"
#import "Measure.h"
#import "Note.h"
#import "Staff.h"
#import "Rest.h"
#import "TimeSignature.h"

@implementation MeasureTest

- (void)setUp{
	staff = [[Staff alloc] initWithSong:nil];
	measure = [staff getLastMeasure];
}
- (void)tearDown{
	[staff release];
}

- (Song *)setupSong{
	Song *song = [[[Song alloc] init] autorelease];
	[staff setSong:song];
	[song setStaffs:[NSMutableArray arrayWithObject:staff]];
	[song setTimeSigs:[NSMutableArray arrayWithObject:[TimeSignature timeSignatureWithTop:4	bottom:4]]];	
	return song;
}

- (void)testGetFirstNote{
	Note *firstNote = [[Note alloc] init];
	Note *secondNote = [[Note alloc] init];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	STAssertEqualObjects([measure getFirstNote], firstNote, @"Wrong note returned.");
	[firstNote release];
	[secondNote release];
}

- (void)testGetTotalDuration{
	Rest *firstRest = [[Rest alloc] initWithDuration:4 dotted:NO];
	Rest *secondRest = [[Rest alloc] initWithDuration:2 dotted:YES];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstRest, secondRest, nil]];
	STAssertEquals([measure getTotalDuration], (float)1.0, @"Wrong total duration returned.");
	[firstRest release];
	[secondRest release];
}

- (void)testIsEmpty{
	STAssertTrue([measure isEmpty], @"isEmpty returned false for empty measure.");
	Note *firstNote = [[Note alloc] init];
	Note *secondNote = [[Note alloc] init];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	STAssertFalse([measure isEmpty], @"isEmpty returned true for non-empty measure.");
	[firstNote release];
	[secondNote release];
}
- (void)testIsFull{
	[self setupSong];
	STAssertFalse([measure isFull], @"isFull returned true for empty measure.");
	Rest *firstRest = [[Rest alloc] initWithDuration:2 dotted:NO];
	Rest *secondRest = [[Rest alloc] initWithDuration:2 dotted:NO];
	[measure setNotes:[NSMutableArray arrayWithObject:firstRest]];
	STAssertFalse([measure isFull], @"isFull returned true for half-full measure.");
	[measure setNotes:[NSMutableArray arrayWithObjects:firstRest, secondRest, nil]];
	STAssertTrue([measure isFull], @"isFull returned false for full measure.");
	[firstRest release];
	[secondRest release];
}

- (void)testGetNoteBefore{
	Note *firstNote = [[Note alloc] init];
	Note *secondNote = [[Note alloc] init];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	STAssertEqualObjects([measure getNoteBefore:secondNote], firstNote, @"Wrong note returned.");
	[firstNote release];
	[secondNote release];	
}
- (void)testGetNoteBeforeFirstNote{
	Note *firstNote = [[Note alloc] init];
	Note *secondNote = [[Note alloc] init];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	STAssertNil([measure getNoteBefore:firstNote], @"Some note before first note returned.");
	[firstNote release];
	[secondNote release];	
}

- (void)testGetNoteStartDuration{
	Rest *firstRest = [[Rest alloc] initWithDuration:4 dotted:NO];
	Rest *secondRest = [[Rest alloc] initWithDuration:2 dotted:YES];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstRest, secondRest, nil]];
	STAssertEquals([measure getNoteStartDuration:secondRest], [firstRest getEffectiveDuration], @"Wrong start duration returned.");
	[firstRest release];
	[secondRest release];
}
- (void)testGetNoteEndDuration{
	Rest *firstRest = [[Rest alloc] initWithDuration:4 dotted:NO];
	Rest *secondRest = [[Rest alloc] initWithDuration:2 dotted:YES];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstRest, secondRest, nil]];
	STAssertEquals([measure getNoteEndDuration:secondRest], [firstRest getEffectiveDuration] + [secondRest getEffectiveDuration], @"Wrong end duration returned.");
	[firstRest release];
	[secondRest release];	
}
- (void)testGetNumberOfNotesStartingAfter{
	Rest *firstRest = [[Rest alloc] initWithDuration:4 dotted:NO];
	Rest *secondRest = [[Rest alloc] initWithDuration:2 dotted:YES];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstRest, secondRest, nil]];
	STAssertEquals([measure getNumberOfNotesStartingAfter:0.0 before:0.25], (int)0, @"Wrong number of notes in time span.");
	STAssertEquals([measure getNumberOfNotesStartingAfter:0.0 before:0.26], (int)1, @"Wrong number of notes in time span.");
	STAssertEquals([measure getNumberOfNotesStartingAfter:-0.1 before:0.26], (int)2, @"Wrong number of notes in time span.");
	[firstRest release];
	[secondRest release];	
}

- (void)testAddOneNoteToEmptyMeasure{
	[self setupSong];
	Note *note = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC];
	[measure addNotes:[NSArray arrayWithObject:note] atIndex:0];
	STAssertEquals([[measure getNotes] count], (unsigned)1, @"Wrong number of notes in measure after adding one.");
	STAssertEqualObjects([[measure getNotes] objectAtIndex:0], note, @"Wrong first note after adding one.");
	[note release];
}
- (void)testAddOneNoteToFullMeasure{
	[self setupSong];
	Rest *rest = [[Rest alloc] initWithDuration:1 dotted:NO];
	[measure setNotes:[NSMutableArray arrayWithObject:rest]];
	Note *note = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC];	
	[measure addNotes:[NSArray arrayWithObject:note] atIndex:0.5];
	STAssertFalse([[measure getNotes] containsObject:note], @"Note added to already full measure.");
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures after auto-create triggered.");
	STAssertTrue([[[staff getLastMeasure] getNotes] containsObject:note], @"Note not added to next measure.");
	[rest release];
	[note release];
}
- (void)testSplitNoteOnAdd{
	[self setupSong];
	Rest *rest = [[Rest alloc] initWithDuration:2 dotted:YES];
	[measure setNotes:[NSMutableArray arrayWithObject:rest]];
	Note *note = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC];	
	[measure addNotes:[NSArray arrayWithObject:note] atIndex:1];
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures after auto-create triggered.");
	STAssertEquals([[measure getNotes] count], (unsigned)2, @"Half of note not left behind during split add.");
	STAssertEquals([[[measure getNotes] lastObject] getDuration], (int)4, @"Note added to first measure is wrong duration.");
	STAssertEquals([[[staff getLastMeasure] getNotes] count], (unsigned)1, @"Note not added to next measure.");
	STAssertEquals([[[[staff getLastMeasure] getNotes] lastObject] getDuration], (int)4, @"Note added to second measure is wrong duration.");
	STAssertEqualObjects([[[[staff getLastMeasure] getNotes] lastObject] getTieFrom], [[measure getNotes] lastObject], @"Auto-split note not tied.");
	[rest release];
	[note release];
}
- (void)testComplexSplitNoteOnAdd{
	[self setupSong];
	Rest *firstRest = [[Rest alloc] initWithDuration:2 dotted:NO];
	Rest *secondRest = [[Rest alloc] initWithDuration:4 dotted:YES];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstRest, secondRest, nil]];
	Note *note = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:YES accidental:NO_ACC];	
	[measure addNotes:[NSArray arrayWithObject:note] atIndex:2];
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures after auto-create triggered.");
	STAssertEquals([[measure getNotes] count], (unsigned)3, @"Part of note not left behind during split add.");
	STAssertEquals([[[measure getNotes] lastObject] getDuration], (int)8, @"Note added to first measure is wrong duration.");
	STAssertEquals([[[staff getLastMeasure] getNotes] count], (unsigned)2, @"Wrong number of notes added to next measure.");
	STAssertEquals([[[[staff getLastMeasure] getNotes] objectAtIndex:0] getDuration], (int)2, @"First note added to second measure is wrong duration.");
	STAssertEquals([[[[staff getLastMeasure] getNotes] lastObject] getDuration], (int)8, @"Second note added to second measure is wrong duration.");
	STAssertEqualObjects([[[[staff getLastMeasure] getNotes] objectAtIndex:0] getTieFrom], [[measure getNotes] lastObject], @"Auto-split note not tied.");
	STAssertEqualObjects([[[[staff getLastMeasure] getNotes] objectAtIndex:0] getTieTo], [[[staff getLastMeasure] getNotes] lastObject], @"Second part of complex auto-split not tied.");
	[firstRest release];
	[secondRest release];
	[note release];
}

- (void)testInsertIntoTieOnAdd{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC];
	[measure addNotes:[NSArray arrayWithObjects:firstNote, secondNote, nil] atIndex:0];
	[firstNote tieTo:secondNote];
	[secondNote tieFrom:firstNote];
	[measure addNotes:[NSArray arrayWithObject:thirdNote] atIndex:0.5];
	STAssertEqualObjects([firstNote getTieTo], thirdNote, @"Tie not adjusted when adding note between tied notes.");
	STAssertEqualObjects([secondNote getTieFrom], thirdNote, @"Tie not adjusted when adding note between tied notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];	
}

- (void)testBreakTieOnAddWithinMeasure{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC];
	Note *thirdNote = [[Note alloc] initWithPitch:1 octave:0 duration:4 dotted:NO accidental:NO_ACC];
	[measure addNotes:[NSArray arrayWithObjects:firstNote, secondNote, nil] atIndex:0];
	[firstNote tieTo:secondNote];
	[secondNote tieFrom:firstNote];
	[measure addNotes:[NSArray arrayWithObject:thirdNote] atIndex:0.5];
	STAssertNil([firstNote getTieTo], @"Tie not broken when adding note between tied notes.");
	STAssertNil([secondNote getTieFrom], @"Tie not broken when adding note between tied notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
}

- (void)testBreakTieOnAddAtEndOfMeasure{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	Note *thirdNote = [[Note alloc] initWithPitch:1 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	[measure addNotes:[NSArray arrayWithObjects:firstNote, secondNote, nil] atIndex:0];
	[firstNote tieTo:secondNote];
	[secondNote tieFrom:firstNote];
	[measure addNotes:[NSArray arrayWithObject:thirdNote] atIndex:0.5];
	STAssertNil([firstNote getTieTo], @"Tie not broken when adding note between tied notes.");
	STAssertNil([secondNote getTieTo], @"Tie not broken when adding note between tied notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];	
}

- (void)testBreakTieOnAddAtBeginningOfMeasure{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	Note *thirdNote = [[Note alloc] initWithPitch:1 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	[[staff getLastMeasure] addNotes:[NSArray arrayWithObjects:firstNote, secondNote, nil] atIndex:0];
	[firstNote tieTo:secondNote];
	[secondNote tieFrom:firstNote];
	[measure addNotes:[NSArray arrayWithObject:thirdNote] atIndex:0.5];
	STAssertNil([firstNote getTieTo], @"Tie not broken when adding note between tied notes.");
	STAssertNil([secondNote getTieTo], @"Tie not broken when adding note between tied notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];	
}

- (void)testRemoveNote{
	Note *note = [[Note alloc] init];
	[measure setNotes:[NSMutableArray arrayWithObject:note]];
	[measure removeNoteAtIndex:0 temporary:NO];
	STAssertFalse([[measure getNotes] containsObject:note], @"Removing note failed.");
	[note release];
}
- (void)testRemoveNoteGrabsNotesFromNextMeasure{
	[self setupSong];
	Rest *firstRest = [[Rest alloc] initWithDuration:2 dotted:NO];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstRest, firstNote, nil]];
	Measure *secondMeasure = [staff addMeasure];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:secondNote]];
	[measure removeNoteAtIndex:1 temporary:NO];
	STAssertEquals([[measure getNotes] count], (unsigned)2, @"Remove note didn't grab notes from next measure.");
	STAssertEquals([[[measure getNotes] lastObject] getDuration], (int)2, @"Remove note didn't split note from next measure.");
	STAssertEqualObjects([[[measure getNotes] lastObject] getTieTo], [[secondMeasure getNotes] lastObject], @"Remove note didn't tie split notes.");
	[firstRest release];
	[firstNote release];
	[secondNote release];
}

- (void)testTimeSignatureChangedMovesNotesToNextMeasure{
	Song *song = [self setupSong];
	Rest *firstRest = [[Rest alloc] initWithDuration:2 dotted:NO];
	Rest *secondRest = [[Rest alloc] initWithDuration:2 dotted:NO];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstRest, secondRest, nil]];
	[song setTimeSignature:[TimeSignature timeSignatureWithTop:2 bottom:4] atIndex:0];
	[measure timeSignatureChangedFrom:1.0 to:0.5 top:2 bottom:4];
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures resulting from time signature change.");
	STAssertEquals([[measure getNotes] count], (unsigned)1, @"Wrong number of notes left after time signature change.");
	STAssertEquals([measure getTotalDuration], (float)0.5, @"Wrong total duration left in first measure.");
	[firstRest release];
	[secondRest release];
}
- (void)testTimeSignatureChangedGrabsNotesFromNextMeasure{
	Song *song = [self setupSong];
	Measure *secondMeasure = [staff addMeasure];
	Rest *firstRest = [[Rest alloc] initWithDuration:1 dotted:NO];
	Rest *secondRest = [[Rest alloc] initWithDuration:1 dotted:NO];
	[measure setNotes:[NSMutableArray arrayWithObject:firstRest]];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:secondRest]];
	[song setTimeSignature:[TimeSignature timeSignatureWithTop:8 bottom:4] atIndex:0];
	[measure timeSignatureChangedFrom:1.0 to:2.0 top:8 bottom:4];
	STAssertEquals([[measure getNotes] count], (unsigned)2, @"Wrong number of notes left after time signature change.");
	STAssertEquals([measure getTotalDuration], (float)2.0, @"Wrong total duration left in first measure.");
	STAssertEquals([[secondMeasure getNotes] count], (unsigned)0, @"Notes not removed from second measure."); 
	[firstRest release];
	[secondRest release];
}
- (void)testTimeSignatureChangedSplitsNotes{
	Song *song = [self setupSong];
	Measure *secondMeasure = [staff addMeasure];
	Rest *firstRest = [[Rest alloc] initWithDuration:1 dotted:NO];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC];
	[measure setNotes:[NSMutableArray arrayWithObject:firstRest]];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:secondNote]];
	[song setTimeSignature:[TimeSignature timeSignatureWithTop:6 bottom:4] atIndex:0];
	[measure timeSignatureChangedFrom:1.0 to:1.5 top:6 bottom:4];
	STAssertEquals([[measure getNotes] count], (unsigned)2, @"Wrong number of notes left after time signature change.");
	STAssertEquals([measure getTotalDuration], (float)1.5, @"Wrong total duration left in first measure.");
	STAssertEquals([[secondMeasure getNotes] count], (unsigned)1, @"Wrong number of notes left in second measure.");
	STAssertEquals([secondMeasure getTotalDuration], (float)0.5, @"Wrong total duration left in second measure.");
	STAssertEqualObjects([[[measure getNotes] lastObject] getTieTo], [[secondMeasure getNotes] objectAtIndex:0], @"Change time signature didn't tie split notes.");
	[firstRest release];
	[secondNote release];
}

@end
