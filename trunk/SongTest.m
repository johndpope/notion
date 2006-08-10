//
//  SongTest.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/9/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SongTest.h"
#import "Song.h"
#import "Staff.h"
#import "TempoData.h"

@implementation SongTest

- (void) setUp{
	song = [[Song alloc] init];
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

@end
