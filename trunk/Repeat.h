//
//  Repeat.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 12/12/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Song;

@interface Repeat : NSObject {
	Song *song;
	int startMeasure, endMeasure, numRepeats;
}

- (id) initWithSong:(Song *)_song;

- (int) startMeasure;
- (int) endMeasure;
- (int) numRepeats;

- (void) setStartMeasure:(int)_startMeasure;
- (void) setEndMeasure:(int)_endMeasure;
- (void) setNumRepeats:(int)_numRepeats;

@end
