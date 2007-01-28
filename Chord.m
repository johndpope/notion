//
//  Chord.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/30/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
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

- (id)initWithStaff:(Staff *)_staff withNotes:(NSMutableArray *)_notes{
	if(self = [super init]){
		staff = _staff;
		notes = [[NSMutableArray arrayWithArray:_notes] retain];
	}
	return self;
}

- (id)initWithStaff:(Staff *)_staff withNotes:(NSArray *)_notes copyItems:(BOOL)_copyItems{
	if(self = [super init]){
		staff = _staff;
		notes = [[[NSMutableArray alloc] initWithArray:_notes copyItems:_copyItems] retain];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone{
	return [[Chord allocWithZone:zone] initWithStaff:staff withNotes:notes copyItems:YES];
}

- (void)setStaff:(Staff *)_staff{
	[super setStaff:_staff];
	[[notes do] setStaff:_staff];
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
	return 4.0 * [self getEffectiveDuration] / 3;
}

- (void)transposeBy:(int)transposeAmount{
	[[notes do] transposeBy:transposeAmount];
}

- (void)prepareForDelete{
	[[notes do] prepareForDelete];
}

- (void)sendChangeNotification{
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"modelChanged" object:self]];
}

- (NSArray *)subtractDuration:(float)maxDuration{
	NSArray *remainingNotes = [[notes collect] subtractDuration:maxDuration];
	NSMutableArray *remainingChords = [[NSMutableArray arrayWithCapacity:[remainingNotes count]] autorelease];
	int i;
	for(i=0; i<[[remainingNotes objectAtIndex:0] count]; i++){
		[remainingChords addObject:[[[Chord alloc] initWithStaff:staff withNotes:[[remainingNotes collect] objectAtIndex:i]] autorelease]];
	}
	return remainingChords;
}

- (void)tryToFill:(float)maxDuration{
	[[notes do] tryToFill:maxDuration];
}

- (void)tieTo:(NoteBase *)note{
	
}

- (NoteBase *)getTieTo{
	return nil;
}

- (void)tieFrom:(NoteBase *)note{
	
}

- (NoteBase *)getTieFrom{
	return nil;
}

- (NSArray *)getNotes{
	return notes;
}

- (NoteBase *)highestNote{
	NoteBase *highestNote = nil;
	NSEnumerator *notesEnum = [notes objectEnumerator];
	id note;
	while(note = [notesEnum nextObject]){
		if(highestNote == nil || [note isHigherThan:highestNote]){
			highestNote = note;
		}
	}
	return highestNote;
}

- (NoteBase *)lowestNote{
	NoteBase *lowestNote = nil;
	NSEnumerator *notesEnum = [notes objectEnumerator];
	id note;
	while(note = [notesEnum nextObject]){
		if(lowestNote == nil || [note isLowerThan:lowestNote]){
			lowestNote = note;
		}
	}
	return lowestNote;
}

- (void) setNotes:(NSMutableArray *)_notes{
	[self prepUndo];
	if(![notes isEqual:_notes]){
		[notes release];
		notes = [_notes retain];
	}
	[self sendChangeNotification];
}

- (void)prepUndo{
	[[[self undoManager] prepareWithInvocationTarget:self] setNotes:[NSMutableArray arrayWithArray:notes]];	
}

- (void)addNote:(NoteBase *)note{
	[self prepUndo];
	if([self getDuration] != 0){
		[note setDuration:[self getDuration]];		
		[note setDotted:[self getDotted]];
	}
	[notes addObject:note];
	[self sendChangeNotification];
}

- (void)removeNote:(NoteBase *)note{
	[self prepUndo];
	[notes removeObject:note];
	[self sendChangeNotification];
}

- (int)getEffectivePitchWithKeySignature:(KeySignature *)keySig priorAccidentals:(NSMutableDictionary *)accidentals{
	[[notes do] getEffectivePitchWithKeySignature:keySig priorAccidentals:accidentals];
	return 0;
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:notes forKey:@"notes"];
	[coder encodeObject:staff forKey:@"staff"];
}

- (id)initWithCoder:(NSCoder *)coder{
	if(self = [super init]){
		[self setNotes:[coder decodeObjectForKey:@"notes"]];
		[self setStaff:[coder decodeObjectForKey:@"staff"]];
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
