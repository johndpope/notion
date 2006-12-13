//
//  Repeat.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 12/12/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "Repeat.h"


@implementation Repeat

- (id) initWithSong:(Song *)_song{
	if(self = [super init]){
		song = _song;
		startMeasure = -1;
		endMeasure = -1;
		numRepeats = 2;
	}
	return self;
}

- (NSUndoManager *) undoManager{
	return [song undoManager];
}

- (int) startMeasure{
	return startMeasure;
}

- (int) endMeasure{
	return endMeasure;
}

- (int) numRepeats{
	return numRepeats;
}

- (void) setStartMeasure:(int)_startMeasure{
	[[[self undoManager] prepareWithInvocationTarget:self] setStartMeasure:startMeasure];
	startMeasure = _startMeasure;
}

- (void) setEndMeasure:(int)_endMeasure{
	[[[self undoManager] prepareWithInvocationTarget:self] setEndMeasure:endMeasure];
	endMeasure = _endMeasure;
}

- (void) setNumRepeats:(int)_numRepeats{
	[[[self undoManager] prepareWithInvocationTarget:self] setNumRepeats:numRepeats];
	numRepeats = _numRepeats;
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:song forKey:@"song"];
	[coder encodeInt:startMeasure forKey:@"startMeasure"];
	[coder encodeInt:endMeasure forKey:@"endMeasure"];
	[coder encodeInt:numRepeats forKey:@"numRepeats"];
}

- (id)initWithCoder:(NSCoder *)coder{
	song = [coder decodeObjectForKey:@"song"];
	[self setStartMeasure:[coder decodeIntForKey:@"startMeasure"]];
	[self setEndMeasure:[coder decodeIntForKey:@"endMeasure"]];
	[self setNumRepeats:[coder decodeIntForKey:@"numRepeats"]];
}

@end
