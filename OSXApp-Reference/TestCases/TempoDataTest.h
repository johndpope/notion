//
//  TempoDataTest.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class Song;
@class MusicDocument;

@interface TempoDataTest : SenTestCase {
	MusicDocument *doc;
	NSUndoManager *mgr;
	Song *song;	
}

@end
