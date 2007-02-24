//
//  DrumKit.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 12/3/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "DrumKit.h"

static DrumKit *standardKit;

@implementation DrumKit

- (id) initWithPitches:(NSArray *)_pitches octaves:(NSArray *)_octaves names:(NSArray *)_names{
	if(self = [super init]){
		pitches = [[NSMutableArray arrayWithArray:_pitches] retain];
		octaves = [[NSMutableArray arrayWithArray:_octaves] retain];
		names = [[NSMutableArray arrayWithArray:_names] retain];
	}
	return self;	
}

- (BOOL)positionIsValid:(int)position{
	return (position >= 0) && (position < [pitches count]);
}

- (int)getPositionForPitch:(int)pitch withOctave:(int)octave{
	int i;
	for(i = 0; i < [pitches count]; i++){
		if([[pitches objectAtIndex:i] intValue] == pitch &&
		   [[octaves objectAtIndex:i] intValue] == octave){
			return i;
		}
	}
//	NSAssert(NO, @"getPositionForPitch called on DrumKit for invalid pitch and octave");
	return 0;
}

- (int)getPitchForPosition:(int)position{
	if(position < 0){
		position == 0;
	}
	if(position >= [pitches count]){
		position = [pitches count] - 1;
	}
	return [[pitches objectAtIndex:position] intValue];
}

- (int)getOctaveForPosition:(int)position{
	if(position < 0){
		position == 0;
	}
	if(position >= [pitches count]){
		position = [pitches count] - 1;
	}
	return [[octaves objectAtIndex:position] intValue];
}

- (int)getTranspositionFrom:(Clef *)clef{
	return 0;
}

- (NSString *)nameAt:(int)position{
	return [names objectAtIndex:position];
}

+ (DrumKit *)standardKit{
	if(standardKit == nil){
		standardKit = [[DrumKit alloc] initWithPitches:[NSArray arrayWithObjects:[NSNumber numberWithInt:0],
																				 [NSNumber numberWithInt:2],
																				 [NSNumber numberWithInt:7],
																				 [NSNumber numberWithInt:11],
																				 [NSNumber numberWithInt:2],
																				 [NSNumber numberWithInt:6],
																				 [NSNumber numberWithInt:3],
																				 [NSNumber numberWithInt:1], nil]
											   octaves:[NSArray arrayWithObjects:[NSNumber numberWithInt:3],
																				 [NSNumber numberWithInt:3],
																				 [NSNumber numberWithInt:3],
																				 [NSNumber numberWithInt:3],
																				 [NSNumber numberWithInt:4],
																				 [NSNumber numberWithInt:3],
																				 [NSNumber numberWithInt:4],
																				 [NSNumber numberWithInt:4], nil]
												 names:[NSArray arrayWithObjects:@"Kick",
																				 @"Snare",
																				 @"Low Tom",
																				 @"Med Tom",
																				 @"Hi Tom",
																				 @"Hi Hat",
																				 @"Ride",
																				 @"Crash", nil]];
	}
	return standardKit;
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:pitches forKey:@"pitches"];
	[coder encodeObject:octaves forKey:@"octaves"];
	[coder encodeObject:names forKey:@"names"];
}

- (id)initWithCoder:(NSCoder *)coder{
	if(self = [super init]){
		pitches = [coder decodeObjectForKey:@"pitches"];
		octaves = [coder decodeObjectForKey:@"octaves"];
		names = [coder decodeObjectForKey:@"names"];
	}
	return self;
}

- (void) dealloc {
	[pitches release];
	[octaves release];
	[names release];
	pitches = nil;
	octaves = nil;
	names = nil;
	[super dealloc];
}


@end
