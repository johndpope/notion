//
//  ChordTest.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 10/1/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class Chord;
@class Measure;
@class Staff;
@class MusicDocument;
@class NSUndoManager;
@class Song;

@interface ChordTest : SenTestCase {
	Measure *measure;
	Staff *staff;
	MusicDocument *doc;
	NSUndoManager *mgr;
	Song *song;
	Chord *chord;
}

@end
