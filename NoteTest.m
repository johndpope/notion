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

@end
