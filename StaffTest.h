//
//  StaffTest.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 8/6/06.
//  Copyright (c) 2006 Konstantine Prevas. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class Staff;
@class MusicDocument;
@class Song;
@class Measure;

@interface StaffTest : SenTestCase {
	Measure *measure;
	Staff *staff;
	MusicDocument *doc;
	NSUndoManager *mgr;
	Song *song;
}

@end
