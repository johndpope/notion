//
//  TempoDataTest.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "TempoDataTest.h"
#import "TempoData.h"

extern int enableMIDI;

@implementation TempoDataTest

// ----- undo/redo tests -----

- (void)setUpUndoTest{
	enableMIDI = 0;
	doc = [[MusicDocument alloc] init];
	mgr = [[NSUndoManager alloc] init];
	[doc setUndoManager:mgr];
	song = [[Song alloc] initWithDocument:doc];
}

- (void)tearDownUndoTest{
	[mgr release];
	[doc release];
	[song release];
}

- (void) testUndoRedoSetTempo{
	[self setUpUndoTest];
	TempoData *tempo = [[TempoData alloc] initWithTempo:120.0 withSong:song];
	[tempo setTempo:140.0];
	[mgr undo];
	STAssertEquals([tempo tempo], (float)120.0, @"Failed to undo setting tempo.");
	[mgr redo];
	STAssertEquals([tempo tempo], (float)140.0, @"Failed to redo setting tempo.");
	[self tearDownUndoTest];
}

@end
