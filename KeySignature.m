//
//  KeySignature.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/16/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "KeySignature.h"
#import "Note.h"
#import "Clef.h"

static int majorSharps[18] = {3, -1, -1, 5, -1, 0, 7, -1, 2, -1, -1, 4, -1, 6, -1, 1, -1, -1};
static int majorFlats[18] = {-1, -1, 2, -1, 7, 0, -1, 5, -1, -1, 3, -1, 1, -1, 6, -1, -1, 4};
static int minorSharps[18] = {0, 7, -1, 2, -1, -1, 4, -1, -1, 6, -1, 1, -1, 3, -1, -1, 5, -1};
static int minorFlats[18] = {0, -1, 5, -1, -1, 3, -1, -1, 1, -1, 6, -1, 4, -1, -1, 2, -1, 7};
static int base[7] = {0, 2, 4, 5, 7, 9, 11};
static int sharpLocs[7] = {3, 0, 4, 1, 5, 2, 6};
static int sharpVisLocs[7] = {8, 5, 9, 6, 3, 7, 4};
static int flatLocs[7] = {6, 2, 5, 1, 4, 0, 3};
static int flatVisLocs[7] = {4, 7, 3, 6, 2, 5, 1};

@implementation KeySignature

+ (id)getMajorSignatureAtIndexFromA:(int)index{
	int sharps = majorSharps[index];
	if(sharps == -1){
		int flats = majorFlats[index];
		if(flats == -1){
			return nil;
		} else{
			return [KeySignature getSignatureWithFlats:flats minor:NO];
		}
	} else{
		return [KeySignature getSignatureWithSharps:sharps minor:NO];
	}
}

+ (id)getMinorSignatureAtIndexFromA:(int)index{
	int sharps = minorSharps[index];
	if(sharps == -1){
		int flats = minorFlats[index];
		if(flats == -1){
			return nil;
		} else{
			return [KeySignature getSignatureWithFlats:flats minor:YES];
		}
	} else{
		return [KeySignature getSignatureWithSharps:sharps minor:YES];
	}
}

- (BOOL)isEqualTo:(id)other{
	if(![other isKindOfClass:[self class]]){
		return false;
	}
	int i;
	for(i = 0; i < 8; i++){
		if(pitches[i] != [other getPitchAtPosition:i]){
			return false;
		}
	}
	return true;
}

- (int)getIndexFromA{
	int i;
	if(sharps != 0){
		if(!minor){
			for(i=0; i<18; i++){
				if(majorSharps[i] == sharps) return i;
			}			
		} else{
			for(i=0; i<18; i++){
				if(minorSharps[i] == sharps) return i;
			}			
		}
		return 0;
	} else if(flats != 0){
		if(!minor){
			for(i=0; i<18; i++){
				if(majorFlats[i] == flats) return i;
			}
		} else{
			for(i=0; i<18; i++){
				if(minorFlats[i] == flats) return i;
			}			
		}
		return 0;
	} else if(minor){
		return 0;
	} else{
		return 5;
	}
}

- (BOOL)isMinor{
	return minor;
}

+ (id)getSignatureWithSharps:(int)sharps minor:(BOOL)_minor{
	static NSMutableDictionary *cachedMajorSharps;
	static NSMutableDictionary *cachedMinorSharps;
	if(nil == cachedMajorSharps){
		cachedMajorSharps = [[NSMutableDictionary dictionaryWithCapacity:8] retain];
	}
	if(nil == cachedMinorSharps){
		cachedMinorSharps = [[NSMutableDictionary dictionaryWithCapacity:8] retain];
	}
	NSMutableDictionary *cachedSharps = _minor ? cachedMinorSharps : cachedMajorSharps;
	id sig = [cachedSharps objectForKey:[[[NSNumber alloc] initWithInt:sharps] autorelease]];
	if(nil == sig){
		int pitches[7];
		int i;
		for(i=0; i<7; i++){
			pitches[i] = base[i];
		}
		for(i=0; i<sharps; i++){
			pitches[sharpLocs[i]]++;		
		}
		sig = [[[KeySignature alloc] initWithPitches:pitches sharps:sharps flats:0 minor:_minor] autorelease];
		[cachedSharps setObject:sig forKey:[[[NSNumber alloc] initWithInt:sharps] autorelease]];
	}
	return sig;
}

+ (id)getSignatureWithFlats:(int)flats minor:(BOOL)_minor{
	static NSMutableDictionary *cachedMajorFlats;
	static NSMutableDictionary *cachedMinorFlats;
	if(nil == cachedMajorFlats){
		cachedMajorFlats = [[NSMutableDictionary dictionaryWithCapacity:8] retain];
	}
	if(nil == cachedMinorFlats){
		cachedMinorFlats = [[NSMutableDictionary dictionaryWithCapacity:8] retain];
	}
	NSMutableDictionary *cachedFlats = _minor ? cachedMinorFlats : cachedMajorFlats;
	id sig = [cachedFlats objectForKey:[[[NSNumber alloc] initWithInt:flats] autorelease]];
	if(nil == sig){
		int pitches[7];
		int i;
		for(i=0; i<7; i++){
			pitches[i] = base[i];
		}
		for(i=0; i<flats; i++){
			pitches[flatLocs[i]]--;		
		}
		sig = [[[KeySignature alloc] initWithPitches:pitches sharps:0 flats:flats minor:_minor] autorelease];
		[cachedFlats setObject:sig forKey:[[[NSNumber alloc] initWithInt:flats] autorelease]];
	}
	return sig;
}

- (int)getPitchAtPosition:(int)position{
	return pitches[position];
}

- (int)getAccidentalAtPosition:(int)position{
	if(pitches[position] < base[position]) return FLAT;
	if(pitches[position] > base[position]) return SHARP;
	return NO_ACC;
}

- (int)getNumSharps{
	return sharps;
}

- (int)getNumFlats{
	return flats;
}

- (NSArray *)getSharpsWithClef:(Clef *)clef{
	NSMutableArray *sharpsArray = [NSMutableArray arrayWithCapacity:sharps];
	int i;
	for(i=0; i<sharps; i++){
		[sharpsArray addObject:[[[NSNumber alloc] initWithInt:(sharpVisLocs[i] + [clef getKeySigOffset])] autorelease]];
	}
	return sharpsArray;
}

- (NSArray *)getFlatsWithClef:(Clef *)clef{
	NSMutableArray *flatsArray = [NSMutableArray arrayWithCapacity:flats];
	int i;
	for(i=0; i<flats; i++){
		[flatsArray addObject:[[[NSNumber alloc] initWithInt:(flatVisLocs[i] + [clef getKeySigOffset])] autorelease]];
	}
	return flatsArray;
}

- (id)initWithPitches:(int *)_pitches sharps:(int)_sharps flats:(int)_flats minor:(BOOL)_minor{
	if(self = [super init]){
		int i;
		for(i=0; i<7; i++){
			pitches[i] = _pitches[i];
		}
		sharps = _sharps;
		flats = _flats;
		minor = _minor;
	}
	return self;
}

@end
