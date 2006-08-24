//
//  MeasureTest.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/8/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class Measure;
@class Staff;
@class MusicDocument;
@class NSUndoManager;
@class Song;

@interface MeasureTest : SenTestCase {
	Measure *measure;
	Staff *staff;
	MusicDocument *doc;
	NSUndoManager *mgr;
	Song *song;
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

- (void)testRemoveNote;
- (void)testRemoveNoteGrabsNotesFromNextMeasure;

- (void)testTimeSignatureChangedMovesNotesToNextMeasure;
- (void)testTimeSignatureChangedGrabsNotesFromNextMeasure;
- (void)testTimeSignatureChangedSplitsNotes;

@end
