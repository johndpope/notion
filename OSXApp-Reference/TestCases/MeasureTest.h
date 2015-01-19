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

@end
