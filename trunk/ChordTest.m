//
//  ChordTest.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 10/1/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ChordTest.h"
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

@end
