//
//  Drum.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 2/24/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import "Drum.h"


@implementation Drum

- (id) initWithPitch:(int)_pitch octave:(int)_octave name:(NSString *)_name shortName:(NSString *)_shortName{
	if(self = [super init]){
		pitch = _pitch;
		octave = _octave;
		name = [[NSString stringWithString:_name] retain];
		shortName = [[NSString stringWithString:_shortName] retain];
	}
	return self;
}

- (int) octave{
	return octave;
}
- (int) pitch{
	return pitch;
}
- (NSString *)name{
	return name;
}
- (NSString *)shortName{
	return shortName;
}

- (id)copyWithZone:(NSZone *)zone{
	return [[Drum allocWithZone:zone] initWithPitch:pitch octave:octave name:name];
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeInt:pitch forKey:@"pitch"];
	[coder encodeInt:octave forKey:@"octave"];
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:shortName forKey:@"shortName"];
}

- (id)initWithCoder:(NSCoder *)coder{
	if(self = [super init]){
		pitch = [coder decodeIntForKey:@"pitch"];
		octave = [coder decodeIntForKey:@"octave"];
		name = [[NSString stringWithString:[coder decodeObjectForKey:@"name"]] retain];
		shortName = [[NSString stringWithString:[coder decodeObjectForKey:@"shortName"]] retain];
	}
	return self;
}

- (BOOL)isEqual:(id)otherDrum{
	return [otherDrum pitch] == pitch && [otherDrum octave] == octave;
}

- (unsigned)hash{
	return octave * 12 + pitch;
}

- (void)dealloc{
	[name release];
	[shortName release];
	name = nil;
	shortName = nil;
	[super dealloc];
}

@end
