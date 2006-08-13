//
//  StaffTest.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/6/06.
//  Copyright (c) 2006 Konstantine Prevas. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class Staff;

@interface StaffTest : SenTestCase {
	Staff *staff;
}

- (void) testGetClefForMeasureWhenMeasureHasClef;
- (void) testGetClefForMeasureWhenPreviousMeasureHasClef;

- (void) testGetKeySignatureForMeasureWhenMeasureHasKeySignature;
- (void) testGetKeySignatureForMeasureWhenPreviousMeasureHasKeySignature;

- (void) testGetEffectiveTimeSignatureForMeasureWhenMeasureHasEffectiveTimeSignature;
- (void) testGetEffectiveTimeSignatureForMeasureWhenPreviousMeasureHasEffectiveTimeSignature;

- (void) testGetLastMeasure;

- (void) testGetMeasureAfter;
- (void) testGetMeasureAfterCreatesNewMeasure;

- (void) testGetMeasureBefore;
- (void) testGetMeasureBeforeFirstMeasure;

- (void) testGetMeasureContainingNote;

- (void) testCleanEmptyMeasures;

- (void) testFindPreviousNoteMatchingInSameMeasure;
- (void) testFindPreviousNoteMatchingInPreviousMeasure;
- (void) testFindPreviousNoteMatchingWhenNoSuchNoteExists;
- (void) testFindPreviousNoteMatchingDoesntReturnNonContiguousNote;


@end
