//
//  SongTest.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/9/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class Song;
@class Staff;
@class MusicDocument;

@interface SongTest : SenTestCase {
	Staff *staff;
	MusicDocument *doc;
	NSUndoManager *mgr;
	Song *song;
}

@end
