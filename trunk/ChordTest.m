//
//  ChordTest.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 10/1/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ChordTest.h"
#import "Measure.h"
#import "Note.h"

@implementation ChordTest

- (void)setUp{
	chord = [[Chord alloc] initWithStaff:nil];
	int i;
	for(i=0; i<3; i++){
		[chord addNote:[[Note alloc] initWithPitch:3 octave:4 duration:2 dotted:YES accidental:NO_ACC onStaff:nil]];
	}
}
- (void)tearDown{
	NSEnumerator *notes = [[chord getNotes] objectEnumerator];
	id note;
	while(note = [notes nextObject]){
		[note release];
	}
	[chord release];
}

- (void) testGetEffectiveDuration{
	STAssertEquals([chord getEffectiveDuration], (float)0.75, @"Wrong duration returned for chord.");
}

- (void) testSetDuration{
	[(NoteBase *)chord setDuration:4];
	STAssertEquals([chord getEffectiveDuration], (float)0.375, @"Setting chord duration failed.");
	[(NoteBase *)chord setDuration:2];
}

- (void) testRemoveDuration{
	NSArray *array = [chord removeDuration:0.375];
	STAssertEquals([chord getEffectiveDuration], (float)0.375, @"Wrong duration left after removing duration from chord.");
	STAssertEquals([array count], (unsigned)1, @"Wrong number of chords split off when removing duration.");
	STAssertEquals([[[array objectAtIndex:0] getNotes] count], (unsigned)3, @"Wrong number of notes in split off chord.");
}

// undo/redo tests

- (void)setUpUndoTest{
	doc = [[MusicDocument alloc] init];
	mgr = [[NSUndoManager alloc] init];
	[doc setUndoManager:mgr];
	song = [[Song alloc] initWithDocument:doc];
	staff = [[song staffs] lastObject];
	[chord setStaff:staff];
	measure = [staff getLastMeasure];
	[measure addNote:chord atIndex:-0.5 tieToPrev:NO];
}

- (void)tearDownUndoTest{
	[song release];
	[mgr release];
	[doc release];	
}

- (void) testUndoRedoAddNote{
	[self setUpUndoTest];
	[mgr beginUndoGrouping];
	Note *note = [[Note alloc] initWithPitch:0 octave:0 duration:2 dotted:YES accidental:NO_ACC onStaff:staff];
	[chord addNote:note];
	[mgr endUndoGrouping];
	[mgr undo];
	STAssertEquals([[chord getNotes] count], (unsigned)3, @"Failed to undo adding note to chord");
	[mgr redo];
	STAssertEquals([[chord getNotes] count], (unsigned)4, @"Failed to redo adding note to chord");
	[self tearDownUndoTest];
}

- (void) testUndoRedoRemoveNote{
	[self setUpUndoTest];
	[mgr beginUndoGrouping];
	Note *note = [[chord getNotes] objectAtIndex:1];
	[chord removeNote:note];
	[mgr endUndoGrouping];
	[mgr undo];
	STAssertEquals([[chord getNotes] count], (unsigned)3, @"Failed to undo removing note from chord");
	[mgr redo];
	STAssertEquals([[chord getNotes] count], (unsigned)2, @"Failed to redo removing note from chord");
	[self tearDownUndoTest];
}

@end
