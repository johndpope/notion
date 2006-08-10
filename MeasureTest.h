//
//  MeasureTest.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/8/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class Measure;
@class Staff;

@interface MeasureTest : SenTestCase {
	Measure *measure;
	Staff *staff;
}

- (void)testGetFirstNote;

- (void)testGetTotalDuration;

- (void)testIsEmpty;
- (void)testIsFull;

- (void)testGetNoteBefore;
- (void)testGetNoteBeforeFirstNote;

- (void)testGetNoteStartDuration;
- (void)testGetNoteEndDuration;
- (void)testGetNumberOfNotesStartingAfter;

- (void)testAddOneNoteToEmptyMeasure;
- (void)testAddOneNoteToFullMeasure;
- (void)testSplitNoteOnAdd;
- (void)testComplexSplitNoteOnAdd;

- (void)testAddOneRestToEmptyMeasure;
- (void)testAddOneRestToFullMeasure;
- (void)testSplitRestOnAdd;
- (void)testComplexSplitRestOnAdd;

- (void)testRemoveNote;
- (void)testRemoveNoteGrabsNotesFromNextMeasure;

@end
