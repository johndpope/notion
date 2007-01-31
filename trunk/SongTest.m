//
//  SongTest.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/9/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "SongTest.h"
#import "Song.h"
#import "Staff.h"
#import "Measure.h"
#import "TempoData.h"
#import "TimeSignature.h"
#import "Note.h"
#include "TestUtil.h"

@implementation SongTest

- (void) setUp{
	song = [[Song alloc] initWithDocument:nil];
}
- (void) tearDown{
	[song release];
}

- (void) testRefreshTempoDataRemovesTempoData{
	TempoData *firstData = [[song tempoData] lastObject];
	TempoData *secondData = [[TempoData alloc] init];
	[song setTempoData:[NSMutableArray arrayWithObjects:firstData, secondData, nil]];
	[song refreshTempoData];
	STAssertEquals([[song tempoData] count], (unsigned)1, @"Wrong number of tempo data left.");
	STAssertEqualObjects([[song tempoData] lastObject], firstData, @"Wrong tempo data removed.");
	[secondData release];
}
- (void) testRefreshTempoDataAddsTempoData{
	[[[song staffs] lastObject] addMeasure];
	[song refreshTempoData];
	STAssertEquals([[song tempoData] count], (unsigned)2, @"Wrong number of tempo data created.");
}

- (void) testGetEffectiveTimeSigForMeasureWithTimeSig{
	STAssertNotNil([song getEffectiveTimeSignatureAt:0], @"Error getting time signature from measure, or SongTest has bad assumption about initialization of Song.");
}
- (void) testGetEffectiveTimeSigForMeasureWithoutTimeSig{
	[[[song staffs] lastObject] addMeasure];
	[song refreshTimeSigs];
	STAssertEqualObjects([song getTimeSignatureAt:1], [NSNull null], @"Time signature automatically created for new measure.");
	STAssertEqualObjects([song getEffectiveTimeSignatureAt:1], [song getTimeSignatureAt:0], @"Wrong time signature returned.");
}

- (void) testRefreshTimeSigsRemovesTimeSigs{
	TimeSignature *firstSig = [[song timeSigs] lastObject];
	TimeSignature *secondSig = [[TimeSignature alloc] init];
	[song setTimeSigs:[NSMutableArray arrayWithObjects:firstSig, secondSig, nil]];
	[song refreshTimeSigs];
	STAssertEquals([[song timeSigs] count], (unsigned)1, @"Wrong number of time signatures left.");
	STAssertEqualObjects([[song timeSigs] lastObject], firstSig, @"Wrong time signature removed.");
	[secondSig release];
}
- (void) testRefreshTimeSigsAddsTimeSigs{
	[[[song staffs] lastObject] addMeasure];
	[song refreshTimeSigs];
	STAssertEquals([[song timeSigs] count], (unsigned)2, @"Wrong number of time signatures created.");	
}

- (void) testDeleteTimeSig{
	[[[song staffs] lastObject] addMeasure];
	Measure *measure = [[[song staffs] lastObject] getMeasureAtIndex:1];
	[song refreshTimeSigs];
	[song setTimeSignature:[TimeSignature timeSignatureWithTop:7 bottom:8] atIndex:1];
	TimeSignature *sig = [measure getEffectiveTimeSignature];
	STAssertEquals([sig getTop], 7, @"Setting time signature failed.");
	STAssertEquals([sig getBottom], 8, @"Setting time signature failed.");
	[song timeSigDeletedAtIndex:1];
	sig = [measure getEffectiveTimeSignature];
	STAssertEquals([sig getTop], 4, @"Deleting time signature failed.");
	STAssertEquals([sig getBottom], 4, @"Deleting time signature failed.");	
}

// ----- undo/redo tests -----

- (void)setUpUndoTest{
	doc = [[MusicDocument alloc] init];
	mgr = [[NSUndoManager alloc] init];
	[doc setUndoManager:mgr];
	[song release];
	song = [[Song alloc] initWithDocument:doc];
	staff = [[song staffs] lastObject];
}

- (void)tearDownUndoTest{
	[mgr release];
	[doc release];	
}

- (void) testUndoRedoAddStaff{
	[self setUpUndoTest];
	Staff *secondStaff = [song addStaff];
	[mgr undo];
	STAssertEquals([[song staffs] count], (unsigned)1, @"Wrong number of staffs after undoing add.");
	STAssertEqualObjects([[song staffs] lastObject], staff, @"Wrong staff left after undoing add.");
	[mgr redo];
	STAssertEquals([[song staffs] count], (unsigned)2, @"Wrong number of staffs after redoing add.");
	STAssertEqualObjects([[song staffs] lastObject], secondStaff, @"Wrong last staff after redoing add.");
	[self tearDownUndoTest];
}
- (void) testUndoRedoRemoveStaff{
	[self setUpUndoTest];
	Staff *secondStaff = [song addStaff];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[song removeStaff:secondStaff];
	[mgr undo];
	STAssertEquals([[song staffs] count], (unsigned)2, @"Wrong number of staffs after undoing remove.");
	STAssertEqualObjects([[song staffs] lastObject], secondStaff, @"Wrong last staff after undoing remove.");
	[mgr redo];
	STAssertEquals([[song staffs] count], (unsigned)1, @"Wrong number of staffs after redoing remove.");
	STAssertEqualObjects([[song staffs] lastObject], staff, @"Wrong staff left after redoing remove.");
	[self tearDownUndoTest];
}
- (void) testUndoRedoRemoveLastStaff{
	[self setUpUndoTest];
	[song removeStaff:staff];
	Staff *newStaff = [[song staffs] lastObject];
	[mgr undo];
	STAssertEquals([[song staffs] count], (unsigned)1, @"Wrong number of staffs after undoing remove.");
	STAssertEqualObjects([[song staffs] lastObject], staff, @"Wrong staff left after undoing remove.");
	[mgr redo];
	STAssertEquals([[song staffs] count], (unsigned)1, @"Wrong number of staffs after redoing remove.");
	STAssertEqualObjects([[song staffs] lastObject], newStaff, @"Wrong staff left after redoing remove.");
	[self tearDownUndoTest];
}

- (void) testUndoRedoSetTimeSig{
	[self setUpUndoTest];
	Measure *measure = [staff getLastMeasure];
	Measure *secondMeasure = [staff addMeasure];
	Measure *thirdMeasure = [staff addMeasure];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[song timeSigChangedAtIndex:1 top:3 bottom:4];
	[mgr undo];
	STAssertEquals([[measure getEffectiveTimeSignature] getMeasureDuration], effDuration(1, NO), @"Previous measure affected by undoing time signature change.");
	STAssertEquals([[secondMeasure getEffectiveTimeSignature] getMeasureDuration], effDuration(1, NO), @"Failed to undo time signature change.");
	STAssertEquals([[thirdMeasure getEffectiveTimeSignature] getMeasureDuration], effDuration(1, NO), @"Following measure not affected by undoing time signature change.");
	[mgr redo];
	STAssertEquals([[measure getEffectiveTimeSignature] getMeasureDuration], effDuration(1, NO), @"Previous measure affected by redoing time signature change.");
	STAssertEquals([[secondMeasure getEffectiveTimeSignature] getMeasureDuration], effDuration(2, YES), @"Failed to redo time signature change.");
	STAssertEquals([[thirdMeasure getEffectiveTimeSignature] getMeasureDuration], effDuration(2, YES), @"Following measure not affected by redoing time signature change.");
	[self tearDownUndoTest];
}
- (void) testUndoRedoSetTimeSigPreservesNotesWhenShrinking{
	[self setUpUndoTest];
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *fourthNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:firstNote atIndex:-0.5 tieToPrev:NO];
	[measure addNote:secondNote atIndex:0.5 tieToPrev:NO];
	[measure addNote:thirdNote atIndex:1.5 tieToPrev:NO];
	[measure addNote:fourthNote atIndex:2.5 tieToPrev:NO];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[song timeSigChangedAtIndex:0 top:3 bottom:4];
	[mgr undo];
	STAssertTrue([[measure getNotes] containsObject:firstNote], @"Lost note not regained after undoing time signature change.");
	STAssertTrue([[measure getNotes] containsObject:secondNote], @"Lost note not regained after undoing time signature change.");
	STAssertTrue([[measure getNotes] containsObject:thirdNote], @"Lost note not regained after undoing time signature change.");
	STAssertTrue([[measure getNotes] containsObject:fourthNote], @"Lost note not regained after undoing time signature change.");
	[mgr redo];
	STAssertEquals([[staff getMeasures] count], (unsigned)2, @"Wrong number of measures after redoing time signature change.");	
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
	[self tearDownUndoTest];
}
- (void) testUndoChangingTimeSigDoesntLoseNotes{
	[self setUpUndoTest];
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:firstNote atIndex:-0.5 tieToPrev:NO];
	[measure addNote:secondNote atIndex:0.5 tieToPrev:NO];
	[measure addNote:thirdNote atIndex:1.5 tieToPrev:NO];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[song timeSigChangedAtIndex:0 top:4 bottom:8];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[song timeSigChangedAtIndex:0 top:5 bottom:8];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[song timeSigChangedAtIndex:0 top:6 bottom:8];
	[mgr undo];
	[mgr undo];
	STAssertEquals([[staff getLastMeasure] getTotalDuration], effDuration(4, NO), @"Notes not preserved after undoing time signature change.");
}
- (void) testUndoRedoSetTimeSigPreservesNotesWhenGrowing{
	[self setUpUndoTest];
	Measure *measure = [staff getLastMeasure];
	Note *firstNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *secondNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *thirdNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	Note *fourthNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[measure addNote:firstNote atIndex:-0.5 tieToPrev:NO];
	[measure addNote:secondNote atIndex:0.5 tieToPrev:NO];
	[measure addNote:thirdNote atIndex:1.5 tieToPrev:NO];
	[measure addNote:fourthNote atIndex:2.5 tieToPrev:NO];
	Measure *secondMeasure = [staff getLastMeasure];
	Note *fifthNote = [[Note alloc] initWithPitch:0 octave:0 duration:4 dotted:NO accidental:NO_ACC onStaff:staff];
	[secondMeasure addNote:fifthNote atIndex:-0.5 tieToPrev:NO];
	[mgr endUndoGrouping];
	[mgr beginUndoGrouping];
	[song timeSigChangedAtIndex:0 top:5 bottom:4];
	[mgr undo];
	STAssertFalse([[measure getNotes] containsObject:fifthNote], @"Grabbed note not relinquished after undoing time signature change.");
	STAssertTrue([[secondMeasure getNotes] containsObject:fifthNote], @"Lost note not regained after undoing time signature change.");
	[mgr redo];
	STAssertFalse([[secondMeasure getNotes] containsObject:fifthNote], @"Lost note not lost again after redoing time signature change.");
	STAssertTrue([[measure getNotes] containsObject:fifthNote], @"Note not grabbed again after redoing time signature change.");	
	[firstNote release];
	[secondNote release];
	[thirdNote release];
	[fourthNote release];
	[fifthNote release];
	[self tearDownUndoTest];
}

@end
