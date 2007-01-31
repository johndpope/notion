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
			accidentals:(NSMutableDictionary *)accidentals transpose:(int)transposition onChannel:(int)channel{
	return 4.0 * [self getEffectiveDuration] / 3;
}

- (BOOL)canBeInChord{
	return NO;
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:staff forKey:@"staff"];
	[coder encodeInt:duration forKey:@"duration"];
	[coder encodeBool:dotted forKey:@"dotted"];
}

- (id)initWithCoder:(NSCoder *)coder{
	if(self = [super init]){
		staff = [coder decodeObjectForKey:@"staff"];
		duration = [coder decodeIntForKey:@"duration"];
		dotted = [coder decodeBoolForKey:@"dotted"];
	}
	return self;
}

- (Class)getViewClass{
	return [RestDraw class];
}

@end
