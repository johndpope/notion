//
//  NoteTest.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/17/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class Note;
@class Measure;
@class Staff;
@class MusicDocument;
@class NSUndoManager;
@class Song;

@interface NoteTest : SenTestCase {
	Note *note;
	Measure *measure;
	Staff *staff;
	MusicDocument *doc;
	NSUndoManager *mgr;
	Song *song;
}

@end
