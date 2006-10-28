//
//  Rest.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/26/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "Rest.h"
#import "RestDraw.h";

@implementation Rest

- (id)initWithDuration:(int)_duration dotted:(BOOL)_dotted onStaff:(Staff *)_staff{
	if(self = [super init]){
		duration = _duration;
		dotted = _dotted;
		staff = _staff;
	}
	return self;
}

- (void)transposeBy:(int)transposeAmount{
	//do nothing
}

- (id)copyWithZone:(NSZone *)zone{
	return [[Rest allocWithZone:zone] initWithDuration:duration dotted:dotted onStaff:staff];
}

- (float)addToMIDITrack:(MusicTrack *)musicTrack atPosition:(float)pos withKeySignature:(KeySignature *)keySig 
			accidentals:(NSMutableDictionary *)accidentals onChannel:(int)channel{
	return 4.0 * [self getEffectiveDuration] / 3;
}

- (Class)getViewClass{
	return [RestDraw class];
}

@end
