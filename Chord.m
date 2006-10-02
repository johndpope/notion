//
//  Chord.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/30/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Chord.h"
#import <Chomp/Chomp.h>
@class ChordDraw;
@class ChordController;

@implementation Chord

- (id)initWithStaff:(Staff *)_staff{
	if(self = [super init]){
		staff = _staff;
		notes = [[NSMutableArray arrayWithCapacity:3] retain];
	}
	return self;
}

- (id)initWithStaff:(Staff *)_staff withNotes:(NSArray *)_notes{
	if(self = [super init]){
		staff = _staff;
		notes = [_notes copy];
	}
	return self;
}

- (id)initWithStaff:(Staff *)_staff withNotes:(NSArray *)_notes copyItems:(BOOL)_copyItems{
	if(self = [super init]){
		staff = _staff;
		notes = [[[NSArray alloc] initWithArray:_notes copyItems:_copyItems] retain];
	}
}

- (id)copyWithZone:(NSZone *)zone{
	return [[Chord allocWithZone:zone] initWithStaff:staff withNotes:notes copyItems:YES];
}

- (int)getDuration{
	if([notes count] > 0){
		return [[notes objectAtIndex:0] getDuration];
	} else{
		return 0;
	}
}
- (BOOL)getDotted{
	if([notes count] > 0){
		return [[notes objectAtIndex:0] getDotted];
	} else{
		return NO;
	}
}

- (void)setDuration:(int)_duration{
	[(NoteBase *)[notes do] setDuration:_duration];
}
- (void)setDotted:(BOOL)_dotted{
	[[notes do] setDotted:_dotted];
}

- (float)addToMIDITrack:(MusicTrack *)musicTrack atPosition:(float)pos
	   withKeySignature:(KeySignature *)sig accidentals:(NSMutableDictionary *)accidentals
			  onChannel:(int)channel{
	[[notes do] addToMIDITrack:musicTrack atPosition:pos withKeySignature:sig 
				   accidentals:accidentals onChannel:channel];
	return 4.0 * [self getEffectiveDuration];
}

- (void)transposeBy:(int)transposeAmount{
	[[notes transposeBy] transposeAmount];
}

- (void)prepareForDelete{
	[[notes do] prepareForDelete];
}

- (NSArray *)removeDuration:(float)maxDuration{
	NSArray *removedNotes = [[notes collect] removeDuration:maxDuration];
	NSMutableArray *removedChords = [[NSMutableArray arrayWithCapacity:[removedNotes count]] autorelease];
	int i;
	for(i=0; i<[[removedNotes objectAtIndex:0] count]; i++){
		[removedChords addObject:[[[Chord alloc] initWithStaff:staff withNotes:[[removedNotes collect] objectAtIndex:i]] autorelease]];
	}
	return removedChords;
}

- (void)tieTo:(NoteBase *)note{
	
}

- (NoteBase *)getTieTo{

}

- (void)tieFrom:(NoteBase *)note{
	
}

- (NoteBase *)getTieFrom{

}

- (NSArray *)getNotes{
	return notes;
}

- (void)addNote:(NoteBase *)note{
	[notes addObject:note];
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:notes forKey:@"notes"];
}

- (id)initWithCoder:(NSCoder *)coder{
	if(self = [super init]){
		notes = [coder decodeObjectForKey:@"notes"];
	}
	return self;
}

- (Class)getViewClass{
	return [ChordDraw class];
}

- (Class)getControllerClass{
	return [ChordController class];
}

- (void)dealloc{
	[notes release];
	notes = nil;
	[super dealloc];
}

@end
