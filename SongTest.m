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
#import "TempoData.h"

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
	STAssertNotNil([song getEffectiveTimeSignatureAt:0], @"SongTest has bad assumption about initialization of Song.");
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

@end
