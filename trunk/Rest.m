//
//  Rest.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/26/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Rest.h"
@class RestDraw;

@implementation Rest

- (id)initWithDuration:(int)_duration dotted:(BOOL)_dotted{
	if(self = [super init]){
		pitch = -1;
		octave = -1;
		duration = _duration;
		dotted = _dotted;
	}
	return self;
}

- (void)tieTo:(Note *)note{
	//can't tie a rest
}

- (void)tieFrom:(Note *)note{
	//can't tie a rest
}

- (void)transposeBy:(int)transposeAmount{
	//do nothing
}

- (id)copyWithZone:(NSZone *)zone{
	return [[Rest allocWithZone:zone] initWithDuration:duration dotted:dotted];
}

- (float)addToMIDITrack:(MusicTrack *)musicTrack atPosition:(float)pos withKeySignature:(KeySignature *)keySig 
			accidentals:(NSMutableDictionary *)accidentals onChannel:(int)channel{
	return 4.0 * [self getEffectiveDuration];
}
	
- (Class)getViewClass{
	return [RestDraw class];
}

@end
