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
#import "Chord.h"
#import "Staff.h"
#import "Rest.h"
#import "TimeSignature.h"
#import "MusicDocument.h"

@implementation MeasureTest

- (void)setUp{
	staff = [[Staff alloc] initWithSong:nil];
	measure = [staff getLastMeasure];
}
- (void)tearDown{
	[staff release];
}

- (Song *)setupSong{
	Song *song = [[[Song alloc] initWithDocument:nil] autorelease];
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
	Rest *firstRest = [[Rest alloc] initWithDuration:4 dotted:NO onStaff:staff];
	Rest *secondRest = [[Rest alloc] initWithDuration:2 dotted:YES onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstRest, secondRest, nil]];
	STAssertEquals([measure getTotalDuration], (float)3.0, @"Wrong total duration returned.");
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
	Rest *firstRest = [[Rest alloc] initWithDuration:2 dotted:NO onStaff:staff];
	Rest *secondRest = [[Rest alloc] initWithDuration:2 dotted:NO onStaff:staff];
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
	Rest *firstRest = [[Rest alloc] initWithDuration:4 dotted:NO onStaff:staff];
	Rest *secondRest = [[Rest alloc] initWithDuration:2 dotted:YES onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstRest, secondRest, nil]];
	STAssertEquals([measure getNoteStartDuration:secondRest], [firstRest getEffectiveDuration], @"Wrong start duration returned.");
	[firstRest release];
	[secondRest release];
}
- (void)testGetNoteEndDuration{
	Rest *firstRest = [[Rest alloc] initWithDuration:4 dotted:NO onStaff:staff];
	Rest *secondRest = [[Rest alloc] initWithDuration:2 dotted:YES onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstRest, secondRest, nil]];
	STAssertEquals([measure getNoteEndDuration:secondRest], [firstRest getEffectiveDuration] + [secondRest getEffectiveDuration], @"Wrong end duration returned.");
	[firstRest release];
	[secondRest release];	
}
- (void)testGetNumberOfNotesStartingAfter{
	Rest *firstRest = [[Rest alloc] initWithDuration:4 dotted:NO onStaff:staff];
	Rest *secondRest = [[Rest alloc] initWithDuration:2 dotted:YES onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstRest, secondRest, nil]];
	STAssertEquals([measure getNumberOfNotesStartingAfter:0.0 before:0.75], (int)0, @"Wrong number of notes in time span.");
	STAssertEquals([measure getNumberOfNotesStartingAfter:0.0 before:0.76], (int)1, @"Wrong number of notes in time span.");
	STAssertEquals([measure getNumberOfNotesStartingAfter:-0.1 before:0.76], (int)2, @"Wrong number of notes in time span.");
	[firstRest release];
	[secondRest release];	
}

- (void)testAddOneNoteToEmptyMeasure{
	[self setupSong];
	Note *note = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:note atIndex:-0.5 tieToPrev:NO];
	STAssertEquals([[measure getNotes] count], (unsigned)1, @"Wrong number of notes in measure after adding one.");
	STAssertEqualObjects([[measure getNotes] objectAtIndex:0], note, @"Wrong first note after adding one.");
	[note release];
}
- (void)testAddOneNoteToFullMeasure{
	[self setupSong];
	Rest *rest = [[Rest alloc] initWithDuration:1 dotted:NO onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObject:rest]];
	Note *note = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];	
	[measure addNote:note atIndex:0.5 tieToPrev:NO];
	STAssertFalse([[measure getNotes] containsObject:note], @"Note added to already full measure.");
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures after auto-create triggered.");
	STAssertTrue([[[staff getLastMeasure] getNotes] containsObject:note], @"Note not added to next measure.");
	[rest release];
	[note release];
}
- (void)testSplitNoteOnAdd{
	[self setupSong];
	Rest *rest = [[Rest alloc] initWithDuration:2 dotted:YES onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObject:rest]];
	Note *note = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:note atIndex:0.5 tieToPrev:NO];
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
	Rest *firstRest = [[Rest alloc] initWithDuration:2 dotted:NO onStaff:staff];
	Rest *secondRest = [[Rest alloc] initWithDuration:4 dotted:YES onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstRest, secondRest, nil]];
	Note *note = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:YES accidental:NO_ACC onStaff:staff];	
	[measure addNote:note atIndex:1.5 tieToPrev:NO];
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
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	[firstNote tieTo:secondNote];
	[secondNote tieFrom:firstNote];
	[measure addNote:thirdNote atIndex:0.5 tieToPrev:NO];
	STAssertEqualObjects([firstNote getTieTo], thirdNote, @"Tie not adjusted when adding note between tied notes.");
	STAssertEqualObjects([secondNote getTieFrom], thirdNote, @"Tie not adjusted when adding note between tied notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];	
}

- (void)testBreakTieOnAddWithinMeasure{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:1 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	[firstNote tieTo:secondNote];
	[secondNote tieFrom:firstNote];
	[measure addNote:thirdNote atIndex:0.5 tieToPrev:NO];
	STAssertNil([firstNote getTieTo], @"Tie not broken when adding note between tied notes.");
	STAssertNil([secondNote getTieFrom], @"Tie not broken when adding note between tied notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
}

- (void)testBreakTieOnAddAtEndOfMeasure{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:1 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	[firstNote tieTo:secondNote];
	[secondNote tieFrom:firstNote];
	[measure addNote:thirdNote atIndex:0.5 tieToPrev:NO];
	STAssertNil([firstNote getTieTo], @"Tie not broken when adding note between tied notes.");
	STAssertNil([secondNote getTieTo], @"Tie not broken when adding note between tied notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];	
}

- (void)testBreakTieOnAddAtBeginningOfMeasure{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:1 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[[staff getLastMeasure] setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	[firstNote tieTo:secondNote];
	[secondNote tieFrom:firstNote];
	[measure addNote:thirdNote atIndex:0.5 tieToPrev:NO];
	STAssertNil([firstNote getTieTo], @"Tie not broken when adding note between tied notes.");
	STAssertNil([secondNote getTieTo], @"Tie not broken when adding note between tied notes.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];	
}

- (void)testAddTieToPrevWithinMeasure{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:firstNote atIndex:-0.5 tieToPrev:NO];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:secondNote atIndex:0.5 tieToPrev:YES];
	STAssertEqualObjects([firstNote getTieTo], secondNote, @"Note not tied to added note.");
	STAssertEqualObjects([secondNote getTieFrom], firstNote, @"Added note not tied from existing note.");
	[firstNote release];
	[secondNote release];
}
- (void)testAddTieToPrevInPreviousMeasure{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:firstNote atIndex:-0.5 tieToPrev:NO];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:secondNote atIndex:0.5 tieToPrev:YES];
	STAssertEqualObjects([firstNote getTieTo], secondNote, @"Note not tied to added note.");
	STAssertEqualObjects([secondNote getTieFrom], firstNote, @"Added note not tied from existing note.");
	[firstNote release];
	[secondNote release];
}
- (void)testAddTieToPrevTiesAutoSplitNote{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:firstNote atIndex:-0.5 tieToPrev:NO];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:secondNote atIndex:0.5 tieToPrev:YES];
	STAssertNotNil([firstNote getTieTo], @"Note not tied to auto-split added note.");
	[firstNote release];
	[secondNote release];
}
- (void)testAddTieToPrevDoesntTieToInvalidNote{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:firstNote atIndex:-0.5 tieToPrev:NO];
	Note *secondNote = [[Note alloc] initWithPitch:1 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:secondNote atIndex:0.5 tieToPrev:YES];
	STAssertNil([firstNote getTieTo], @"Note tied to added note incorrectly.");
	STAssertNil([secondNote getTieFrom], @"Added note tied from existing note incorrectly.");
	[firstNote release];
	[secondNote release];
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
	Rest *firstRest = [[Rest alloc] initWithDuration:2 dotted:NO onStaff:staff];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
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
	Rest *firstRest = [[Rest alloc] initWithDuration:2 dotted:NO onStaff:staff];
	Rest *secondRest = [[Rest alloc] initWithDuration:2 dotted:NO onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstRest, secondRest, nil]];
	[song setTimeSignature:[TimeSignature timeSignatureWithTop:2 bottom:4] atIndex:0];
	[measure timeSignatureChangedFrom:1.0 to:0.5 top:2 bottom:4];
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures resulting from time signature change.");
	STAssertEquals([[measure getNotes] count], (unsigned)1, @"Wrong number of notes left after time signature change.");
	STAssertEquals([measure getTotalDuration], (float)1.5, @"Wrong total duration left in first measure.");
	[firstRest release];
	[secondRest release];
}
- (void)testTimeSignatureChangedGrabsNotesFromNextMeasure{
	Song *song = [self setupSong];
	Measure *secondMeasure = [staff addMeasure];
	Rest *firstRest = [[Rest alloc] initWithDuration:1 dotted:NO onStaff:staff];
	Rest *secondRest = [[Rest alloc] initWithDuration:1 dotted:NO onStaff:staff];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:secondRest]];
	[measure setNotes:[NSMutableArray arrayWithObject:firstRest]];
	[song setTimeSignature:[TimeSignature timeSignatureWithTop:8 bottom:4] atIndex:0];
	[measure timeSignatureChangedFrom:1.0 to:2.0 top:8 bottom:4];
	STAssertEquals([[measure getNotes] count], (unsigned)2, @"Wrong number of notes left after time signature change.");
	STAssertEquals([measure getTotalDuration], (float)6.0, @"Wrong total duration left in first measure.");
	STAssertEquals([[secondMeasure getNotes] count], (unsigned)0, @"Notes not removed from second measure."); 
	[firstRest release];
	[secondRest release];
}
- (void)testTimeSignatureChangedSplitsNotes{
	Song *song = [self setupSong];
	Measure *secondMeasure = [staff addMeasure];
	Rest *firstRest = [[Rest alloc] initWithDuration:1 dotted:NO onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:secondNote]];
	[measure setNotes:[NSMutableArray arrayWithObject:firstRest]];
	[song setTimeSignature:[TimeSignature timeSignatureWithTop:6 bottom:4] atIndex:0];
	[measure timeSignatureChangedFrom:1.0 to:1.5 top:6 bottom:4];
	STAssertEquals([[measure getNotes] count], (unsigned)2, @"Wrong number of notes left after time signature change.");
	STAssertEquals([measure getTotalDuration], (float)4.5, @"Wrong total duration left in first measure.");
	STAssertEquals([[secondMeasure getNotes] count], (unsigned)1, @"Wrong number of notes left in second measure.");
	STAssertEquals([secondMeasure getTotalDuration], (float)1.5, @"Wrong total duration left in second measure.");
	STAssertEqualObjects([[[measure getNotes] lastObject] getTieTo], [[secondMeasure getNotes] objectAtIndex:0], @"Change time signature didn't tie split notes.");
	[firstRest release];
	[secondNote release];
}

- (void)testReplaceNoteWithChord{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, thirdNote, nil]];
	Note *fourthNote = [[Note alloc] initWithPitch:2 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:fourthNote toChordAtIndex:1];
	NoteBase *newSecondNote = [[measure getNotes] objectAtIndex:1];
	STAssertTrue([newSecondNote isKindOfClass:[Chord class]], @"Failed to create chord from note.");
	STAssertEquals([[newSecondNote getNotes] count], (unsigned)2, @"Wrong number of notes in chord.");
	STAssertTrue([[newSecondNote getNotes] containsObject:secondNote], @"Existing note not in created chord.");
	STAssertTrue([[newSecondNote getNotes] containsObject:fourthNote], @"New note not in created chord.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
}

- (void)testAddNoteToExistingChord{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:1 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Chord *chord = [[Chord alloc] initWithStaff:staff withNotes:[NSMutableArray arrayWithObjects:secondNote, thirdNote, nil]];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, chord, nil]];
	Note *fourthNote = [[Note alloc] initWithPitch:2 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:fourthNote toChordAtIndex:1];
	NoteBase *newSecondNote = [[measure getNotes] objectAtIndex:1];
	STAssertTrue([newSecondNote isKindOfClass:[Chord class]], @"Destroyed chord while adding note.");
	STAssertEquals([[newSecondNote getNotes] count], (unsigned)3, @"Wrong number of notes in chord.");
	STAssertTrue([[newSecondNote getNotes] containsObject:secondNote], @"Existing note not maintained in chord.");
	STAssertTrue([[newSecondNote getNotes] containsObject:thirdNote], @"Existing note not maintained in chord.");
	STAssertTrue([[newSecondNote getNotes] containsObject:fourthNote], @"New note not in chord.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[chord release];
	[fourthNote release];
}

- (void)testAddRestDoesntAddToChord{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:1 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Chord *chord = [[Chord alloc] initWithStaff:staff withNotes:[NSMutableArray arrayWithObjects:secondNote, thirdNote, nil]];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, chord, nil]];
	Note *fourthNote = [[Rest alloc] initWithDuration:4 dotted:NO onStaff:staff];
	[measure addNote:fourthNote atIndex:1 tieToPrev:NO];
	STAssertEquals([[measure getNotes] count], (unsigned)3, @"Wrong number of notes in measure.");
	NoteBase *newSecondNote = [[measure getNotes] objectAtIndex:1];
	NoteBase *newThirdNote = [[measure getNotes] objectAtIndex:2];
	STAssertTrue([newSecondNote isKindOfClass:[Rest class]], @"Rest not inserted before chord.");
	STAssertEquals(newThirdNote, chord, @"Chord not pushed up by inserted rest.");
	STAssertFalse([[chord getNotes] containsObject:fourthNote], @"Rest erroneously added to chord.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[chord release];
	[fourthNote release];
}

- (void)testRemoveNoteFromThreeNoteChord{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:1 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Rest *fourthNote = [[Note alloc] initWithPitch:2 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Chord *chord = [[Chord alloc] initWithStaff:staff withNotes:[NSMutableArray arrayWithObjects:secondNote, thirdNote, fourthNote, nil]];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, chord, nil]];
	[measure removeNote:thirdNote fromChordAtIndex:1];
	NoteBase *newSecondNote = [[measure getNotes] objectAtIndex:1];
	STAssertTrue([newSecondNote isKindOfClass:[Chord class]], @"Destroyed chord while removing note.");
	STAssertEquals([[newSecondNote getNotes] count], (unsigned)2, @"Wrong number of notes in chord.");
	STAssertTrue([[newSecondNote getNotes] containsObject:secondNote], @"Existing note not maintained in chord.");
	STAssertFalse([[newSecondNote getNotes] containsObject:thirdNote], @"Note not removed from chord.");
	STAssertTrue([[newSecondNote getNotes] containsObject:fourthNote], @"Existing note not maintained in chord.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
	[chord release];
}

- (void)testRemoveNoteChangesChordToNote{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:1 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Chord *chord = [[Chord alloc] initWithStaff:staff withNotes:[NSMutableArray arrayWithObjects:secondNote, thirdNote, nil]];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, chord, nil]];
	[measure removeNote:thirdNote fromChordAtIndex:1];
	NoteBase *newSecondNote = [[measure getNotes] objectAtIndex:1];
	STAssertFalse([newSecondNote isKindOfClass:[Chord class]], @"Removing next-to-last note from chord didn't change to single note.");
	STAssertEqualObjects(newSecondNote, secondNote, @"Removing next-to-last note from chord left wrong note behind.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[chord release];
}

- (void)testRefreshNotesConsolidatesTiedNotes{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	[secondNote tieTo:thirdNote];
	[thirdNote tieFrom:secondNote];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	Measure *secondMeasure = [staff addMeasure];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:thirdNote]];
	[measure refreshNotes:firstNote];
	STAssertEquals([[secondMeasure getNotes] count], (unsigned)1, @"Failed to consolidate tied notes on refresh.");
	STAssertEquals([[[secondMeasure getNotes] objectAtIndex:0] getEffectiveDuration], (float)3, @"Consolidated note has wrong duration.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
}

- (void)testRefreshNotesMaintainsTieFromPartiallyConsolidatedNote{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:YES accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	[secondNote tieTo:thirdNote];
	[thirdNote tieFrom:secondNote];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	Measure *secondMeasure = [staff addMeasure];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:thirdNote]];
	[measure refreshNotes:firstNote];
	STAssertEquals([[secondMeasure getNotes] count], (unsigned)1, @"Failed to consolidate tied notes on refresh.");
	STAssertEquals([[[secondMeasure getNotes] objectAtIndex:0] getEffectiveDuration], (float)2.25, @"Consolidated note has wrong duration.");
	STAssertNotNil([[[secondMeasure getNotes] objectAtIndex:0] getTieFrom], @"Partially consolidated note did not maintain tie from previous measure.");
	STAssertEquals([[[[secondMeasure getNotes] objectAtIndex:0] getTieFrom] getEffectiveDuration], (float)0.75, @"Remaining note after consolidation has wrong duration.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
}

- (void)testRefreshNotesWithIncompleteConsolidation{
	[self setupSong];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:YES accidental:NO_ACC onStaff:staff];
	[secondNote tieTo:thirdNote];
	[thirdNote tieFrom:secondNote];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	Measure *secondMeasure = [staff addMeasure];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:thirdNote]];
	[measure refreshNotes:firstNote];
	STAssertEquals([[secondMeasure getNotes] count], (unsigned)2, @"Failed to consolidate tied notes correctly on refresh.");
	STAssertEquals([[[secondMeasure getNotes] objectAtIndex:0] getEffectiveDuration], (float)2.25, @"Consolidated note has wrong duration.");
	STAssertNotNil([[[secondMeasure getNotes] objectAtIndex:0] getTieTo], @"Note lost on incomplete consolidation.");
	STAssertEquals([[[[secondMeasure getNotes] objectAtIndex:0] getTieTo] getEffectiveDuration], (float)0.375, @"Remaining note after consolidation has wrong duration.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
}

- (void)testGrabNotesConsolidatesTiedNotes{
	[self setupSong];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	[secondNote tieTo:thirdNote];
	[thirdNote tieFrom:secondNote];
	[measure setNotes:[NSMutableArray arrayWithObject:secondNote]];
	Measure *secondMeasure = [staff addMeasure];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:thirdNote]];
	[measure grabNotesFromNextMeasure];
	STAssertEquals([[measure getNotes] count], (unsigned)1, @"Failed to consolidate tied notes on grab.");
	STAssertEquals([[[measure getNotes] objectAtIndex:0] getEffectiveDuration], (float)3, @"Consolidated note has wrong duration.");
	[secondNote release];
	[thirdNote release];
}

- (void)testGrabNotesMaintainsTieFromPartiallyConsolidatedNote{
	[self setupSong];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:YES accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	[secondNote tieTo:thirdNote];
	[thirdNote tieFrom:secondNote];
	[measure setNotes:[NSMutableArray arrayWithObject:secondNote]];
	Measure *secondMeasure = [staff addMeasure];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:thirdNote]];
	[measure grabNotesFromNextMeasure];
	STAssertEquals([[measure getNotes] count], (unsigned)1, @"Failed to consolidate tied notes on grab.");
	STAssertEquals([[[measure getNotes] objectAtIndex:0] getEffectiveDuration], (float)3, @"Consolidated note has wrong duration.");
	STAssertNotNil([[[measure getNotes] objectAtIndex:0] getTieTo], @"Partially consolidated note did not maintain tie to next measure.");
	STAssertEquals([[[[measure getNotes] objectAtIndex:0] getTieTo] getEffectiveDuration], (float)0.75, @"Remaining note after consolidation has wrong duration.");
	[secondNote release];
	[thirdNote release];
}

- (void)testGrabNotesWithIncompleteConsolidation{
	[self setupSong];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:YES accidental:NO_ACC onStaff:staff];
	[secondNote tieTo:thirdNote];
	[thirdNote tieFrom:secondNote];
	[measure setNotes:[NSMutableArray arrayWithObject:secondNote]];
	Measure *secondMeasure = [staff addMeasure];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:thirdNote]];
	[measure grabNotesFromNextMeasure];
	STAssertEquals([[measure getNotes] count], (unsigned)2, @"Failed to consolidate tied notes correctly on grab.");
	STAssertEquals([[[measure getNotes] objectAtIndex:0] getEffectiveDuration], (float)2.25, @"Consolidated note has wrong duration.");
	STAssertNotNil([[[measure getNotes] objectAtIndex:0] getTieTo], @"Note lost on incomplete consolidation.");
	STAssertEquals([[[[measure getNotes] objectAtIndex:0] getTieTo] getEffectiveDuration], (float)0.375, @"Remaining note after consolidation has wrong duration.");
	[secondNote release];
	[thirdNote release];	
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

- (void)testUndoRedoAddNote{
	[self setUpUndoTest];
	[mgr beginUndoGrouping];
	Rest *note = [[Rest alloc] initWithDuration:1 dotted:NO onStaff:staff];
	[measure addNote:note atIndex:-0.5 tieToPrev:NO];
	[mgr endUndoGrouping];
	[mgr undo];
	STAssertEquals([[measure getNotes] count], (unsigned)0, @"Failed to undo adding note.");
	[mgr redo];
	STAssertEquals([[measure getNotes] count], (unsigned)1, @"Failed to redo adding note.");
	[note release];
	[self tearDownUndoTest];
}

- (void)testUndoAddNoteUndoesCorrectNote{
	[self setUpUndoTest];
	Rest *firstNote = [[Rest alloc] initWithDuration:2 dotted:NO onStaff:staff];
	[measure addNote:firstNote atIndex:-0.5 tieToPrev:NO];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	Rest *secondNote = [[Rest alloc] initWithDuration:2 dotted:NO onStaff:staff];
	[measure addNote:secondNote atIndex:0.5 tieToPrev:NO];
	[mgr undo];
	STAssertTrue([[measure getNotes] containsObject:firstNote], @"Wrong note removed when undoing add note.");
	STAssertFalse([[measure getNotes] containsObject:secondNote], @"Correct note not removed when undoing add note.");
	[firstNote release];
	[secondNote release];
	[self tearDownUndoTest];
}

- (void)testUndoAddNoteRestoresBrokenTie{
	[self setUpUndoTest];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:1 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:firstNote atIndex:-0.5 tieToPrev:NO];
	[measure addNote:secondNote atIndex:0.5 tieToPrev:NO];
	[firstNote tieTo:secondNote];
	[secondNote tieFrom:firstNote];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[measure addNote:thirdNote atIndex:0.5 tieToPrev:NO];
	[mgr undo];
	STAssertEqualObjects([firstNote getTieTo], secondNote, @"Undoing add note didn't restore broken tie.");
	STAssertEqualObjects([secondNote getTieFrom], firstNote, @"Undoing add note didn't restore broken tie.");
	[mgr redo];
	STAssertNil([firstNote getTieTo], @"Redoing add note didn't re-break tie.");
	STAssertNil([secondNote getTieFrom], @"Redoing add note didn't re-break tie.");
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[self tearDownUndoTest];
}

- (void)testUndoRedoAddSplitNote{
	[self setUpUndoTest];
	Rest *firstNote = [[Rest alloc] initWithDuration:2 dotted:YES onStaff:staff];
	[measure addNote:firstNote atIndex:-0.5 tieToPrev:NO];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:secondNote atIndex:0.5 tieToPrev:NO];
	Note *tieSource = [[measure getNotes] lastObject];
	[mgr undo];
	STAssertEquals([[staff getMeasures] count], (unsigned)1, @"Wrong number of measures left after undoing add of an auto-split note.");
	STAssertEquals([[measure getNotes] count], (unsigned)1, @"Wrong number of notes left in measure after undoing add of an auto-split note.");
	[mgr redo];
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures left after redoing add of an auto-split note.");
	STAssertEquals([[measure getNotes] count], (unsigned)2, @"Wrong number of notes left in measure after redoing add of an auto-split note.");
	STAssertNotNil([tieSource getTieTo], @"Auto-split note no longer tied after redoing add.");
	[firstNote release];
	[secondNote release];
	[self tearDownUndoTest];
}

- (void)testUndoRedoRemoveNote{
	[self setUpUndoTest];
	Note *note = [[Note alloc] init];
	[measure setNotes:[NSMutableArray arrayWithObject:note]];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[measure removeNoteAtIndex:0 temporary:NO];
	[mgr undo];
	STAssertTrue([[measure getNotes] containsObject:note], @"Undoing remove note failed.");
	STAssertEquals([[measure getNotes] count], (unsigned)1, @"Wrong number of notes in measure after undoing remove note.");
	[mgr redo];
	STAssertFalse([[measure getNotes] containsObject:note], @"Redoing remove note failed.");
	STAssertEquals([[measure getNotes] count], (unsigned)0, @"Wrong number of notes in measure after redoing remove note.");
	[note release];
	[self tearDownUndoTest];
}

- (void)testUndoRedoRemoveNoteTwoMeasures{
	[self setUpUndoTest];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObject:firstNote]];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:secondNote atIndex:0.5 tieToPrev:NO];
	Measure *secondMeasure = [staff getMeasureContainingNote:secondNote];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[secondMeasure removeNoteAtIndex:0 temporary:NO];
	[mgr undo];
	STAssertTrue([[secondMeasure getNotes] containsObject:secondNote], @"Undoing remove note failed.");
	STAssertEquals([[secondMeasure getNotes] count], (unsigned)1, @"Wrong number of notes in measure after undoing remove note.");
	[mgr redo];
	STAssertEquals([[staff getMeasures] count], (unsigned)1, @"Wrong number of measures left after redoing remove note.");
	[firstNote release];
	[secondNote release];
	[self tearDownUndoTest];	
}

- (void)testUndoRedoSetKeySig{
	[self setUpUndoTest];
	KeySignature *orig = [measure getKeySignature];
	KeySignature *new = [KeySignature getSignatureWithFlats:4 minor:NO];
	[measure setKeySignature:new];
	[mgr undo];
	STAssertEquals([measure getKeySignature], orig, @"Failed to undo changing key signature.");
	[mgr redo];
	STAssertEquals([measure getKeySignature], new, @"Failed to redo changing key signature.");
	[self tearDownUndoTest];
}

- (void)testUndoAddNoteConsolidatesSplitNote{
	[self setUpUndoTest];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure setNotes:[NSMutableArray arrayWithObject:firstNote]];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[measure addNote:secondNote atIndex:-0.5 tieToPrev:NO];
	[mgr undo];
	STAssertEquals([[measure getNotes] count], (unsigned)1, @"Failed to consolidate notes on undo.");
	[firstNote release];
	[secondNote release];
	[self tearDownUndoTest];
}

- (void)testUndoRemoveNoteConsolidatesSplitNote{
	[self setUpUndoTest];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:1 dotted:NO accidental:NO_ACC onStaff:staff];
	Measure *secondMeasure = [staff addMeasure];
	[measure setNotes:[NSMutableArray arrayWithObjects:firstNote, secondNote, nil]];
	[secondMeasure setNotes:[NSMutableArray arrayWithObject:thirdNote]];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[measure removeNoteAtIndex:0 temporary:NO];
	[mgr undo];
	STAssertEquals([[secondMeasure getNotes] count], (unsigned)1, @"Failed to consolidate notes on undo.");
	[self tearDownUndoTest];
}

@end
