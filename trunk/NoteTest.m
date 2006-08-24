//
//  NoteTest.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/17/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "NoteTest.h"
#import "Note.h"

@implementation NoteTest

- (void)setUp{
	note = [[Note alloc] initWithPitch:4 octave:3 duration:2 dotted:YES accidental:SHARP onStaff:nil];
}
- (void)tearDown{
	[note release];
}

- (void) testGetEffectiveDuration{
	STAssertEquals([note getEffectiveDuration], (float)0.75, @"Wrong duration returned for note.");
}

- (void) testRemoveDuration{
	NSArray *array = [note removeDuration:0.375];
	STAssertEquals([note getEffectiveDuration], (float)0.375, @"Wrong duration left after removing duration from note.");
	STAssertEquals([array count], (unsigned)1, @"Wrong number of notes split off when removing duration.");
}

@end
