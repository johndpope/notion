//
//  Song.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "Song.h"
#import "Staff.h"
#import "Measure.h"
#import "TempoData.h"
#import "TimeSignature.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation Song

- (id)initWithDocument:(MusicDocument *)_doc{
	if((self = [super init])){
		doc = _doc;
		tempoData = [[NSMutableArray arrayWithObject:[[TempoData alloc] initWithTempo:120]] retain];
		staffs = [[NSMutableArray arrayWithObject:[[Staff alloc] initWithSong:self]] retain];
		timeSigs = [[NSMutableArray arrayWithObject:[TimeSignature timeSignatureWithTop:4 bottom:4]] retain];
	}
	return self;
}

- (NSUndoManager *)undoManager{
	return [doc undoManager];
}

- (MusicDocument *)document{
	return doc;
}

- (NSMutableArray *)staffs{
	return staffs;
}

- (void)prepUndo{
	[[[self undoManager] prepareWithInvocationTarget:self] setStaffsAndRefresh:[NSMutableArray arrayWithArray:staffs]];
}

- (void)setStaffsAndRefresh:(NSMutableArray *)_staffs{
	[self setStaffs:_staffs];
	[self refreshTimeSigs];
	[self refreshTempoData];
}

- (void)setStaffs:(NSMutableArray *)_staffs{
	[self prepUndo];
	[self willChangeValueForKey:@"staffs"];
	if(![staffs isEqual:_staffs]){
		[staffs release];
		staffs = [_staffs retain];
	}
	[self didChangeValueForKey:@"staffs"];
}

- (Staff *)addStaff{
	[self prepUndo];
	Staff *staff = [self doAddStaff];
	[self refreshTimeSigs];
	[self refreshTempoData];
	return staff;
}

- (Staff *)doAddStaff{
	Staff *staff = [[Staff alloc] initWithSong:self];
	[staffs addObject:staff];
	return staff;
}

- (void)removeStaff:(Staff *)staff{
	[self prepUndo];
	[self willChangeValueForKey:@"staffs"];
	[staffs removeObject:staff];
	[staff cleanPanels];
	if([staffs count] == 0){
		[self doAddStaff];
	}
	[self refreshTimeSigs];
	[self refreshTempoData];
	[self didChangeValueForKey:@"staffs"];
}

- (float)getTempoAt:(int)measureIndex{
	TempoData *data = [tempoData objectAtIndex:measureIndex];
	while([data empty]){
		data = [tempoData objectAtIndex:--measureIndex];
	}
	return [data tempo];
}

- (void)refreshTempoData{
	[self willChangeValueForKey:@"tempoData"];
	int numMeasures = 0;
	NSEnumerator *staffEnum = [staffs objectEnumerator];
	id staff;
	while(staff = [staffEnum nextObject]){
		if([[staff getMeasures] count] > numMeasures){
			numMeasures = [[staff getMeasures] count];
		}
	}
	while([tempoData count] < numMeasures){
		[tempoData addObject:[[TempoData alloc] initEmpty]];
	}
	while([tempoData count] > numMeasures){
		TempoData *tempo = [tempoData lastObject];
		[tempo removePanel];
		[tempoData removeLastObject];
	}
	[self didChangeValueForKey:@"tempoData"];
}

- (NSMutableArray *)tempoData{
	return tempoData;
}

- (void)setTempoData:(NSMutableArray *)_tempoData{
	if(![tempoData isEqual:_tempoData]){
		[tempoData release];
		tempoData = [_tempoData retain];
	}
}

- (NSMutableArray *)timeSigs{
	return timeSigs;
}

- (void)setTimeSigs:(NSMutableArray *)_timeSigs{
	if(![timeSigs isEqual:_timeSigs]){
		[timeSigs release];
		timeSigs = [_timeSigs retain];
	}
}

- (void)setTimeSignature:(TimeSignature *)sig atIndex:(int)measureIndex{
	[[[self undoManager] prepareWithInvocationTarget:self] setTimeSignature:[timeSigs objectAtIndex:measureIndex] atIndex:measureIndex];
	[timeSigs replaceObjectAtIndex:measureIndex withObject:sig];
}

- (TimeSignature *)getTimeSignatureAt:(int)measureIndex{
	return [timeSigs objectAtIndex:measureIndex];
}

- (TimeSignature *)getEffectiveTimeSignatureAt:(int)measureIndex{
	while([[self getTimeSignatureAt:measureIndex] isKindOfClass:[NSNull class]]){
		if(measureIndex == 0) return [TimeSignature timeSignatureWithTop:4 bottom:4];
		measureIndex--;
	}
	return [self getTimeSignatureAt:measureIndex];
}

- (void)refreshTimeSigs{
	[self willChangeValueForKey:@"timeSigs"];
	int numMeasures = 0;
	NSEnumerator *staffEnum = [staffs objectEnumerator];
	id staff;
	while(staff = [staffEnum nextObject]){
		if([[staff getMeasures] count] > numMeasures){
			numMeasures = [[staff getMeasures] count];
		}
	}
	while([timeSigs count] < numMeasures){
		[timeSigs addObject:[NSNull null]];
	}
	while([timeSigs count] > numMeasures){
		[timeSigs removeLastObject];
	}
	[self didChangeValueForKey:@"timeSigs"];
}

- (void)timeSigChangedAtIndex:(int)measureIndex top:(int)top bottom:(int)bottom{
	TimeSignature *oldEffSig = [self getEffectiveTimeSignatureAt:measureIndex];
	float oldTotal = [oldEffSig getMeasureDuration];
	TimeSignature *sig = [TimeSignature timeSignatureWithTop:top bottom:bottom];
	[self setTimeSignature:sig atIndex:measureIndex];
	float newTotal = [sig getMeasureDuration];
	NSEnumerator *staffsEnum = [staffs objectEnumerator];
	id staff;
	while(staff = [staffsEnum nextObject]){
		if([[staff getMeasures] count] > measureIndex){
			[[[staff getMeasures] objectAtIndex:measureIndex] timeSignatureChangedFrom:oldTotal
				to:newTotal top:top bottom:bottom];
		}
	}
}

- (void)playToEndpoint:(MIDIEndpointRef)endpoint{
	MusicSequence musicSequence;
	if (NewMusicSequence(&musicSequence) != noErr)
		[NSException raise:@"main" format:@"Cannot create music sequence."];
	NSEnumerator *staffsEnum = [staffs objectEnumerator];
	id staff;
	while(staff = [staffsEnum nextObject]){
		[staff addTrackToMIDISequence:&musicSequence];
	}
	
	MusicTrack tempoTrack;
	if (MusicSequenceGetTempoTrack(musicSequence, &tempoTrack) != noErr)
		[NSException raise:@"main" format:@"Cannot get tempo track."];

	NSEnumerator *tempoEnum = [tempoData objectEnumerator];
	id tempo;
	float time = 0;
	float currTempo = 0;
	int i = 0;
	while(tempo = [tempoEnum nextObject]){
		if(![tempo empty]){
			MusicTrackNewExtendedTempoEvent(tempoTrack, time, [tempo tempo]);
			currTempo = [tempo tempo];
		}
		time += [[[[staffs objectAtIndex:0] getMeasures] objectAtIndex:i] getTotalDuration] * 4;
		i++;
	}
	
	if(endpoint != nil){
		if (MusicSequenceSetMIDIEndpoint(musicSequence, endpoint) != noErr)
			[NSException raise:@"setMIDIEndpoint" format:@"Can't set midi endpoint for music sequence"];
	}
	
	MusicPlayer musicPlayer;
	if (NewMusicPlayer(&musicPlayer) != noErr) {
		NSLog(@"Cannot create music player.");
		return;
	}

	if (MusicPlayerSetSequence(musicPlayer, musicSequence) != noErr) {
		NSLog(@"Cannot set sequence for music player.");
		return;
	}

	MusicPlayerSetTime(musicPlayer, 0.0);
	MusicPlayerPreroll(musicPlayer);

	if (MusicPlayerStart(musicPlayer) != noErr) {
		NSLog(@"Cannot start music player.");
		return;
	}

}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:staffs forKey:@"staffs"];
	[coder encodeObject:tempoData forKey:@"tempoData"];
	[coder encodeObject:timeSigs forKey:@"timeSigs"];
}

- (id)initWithCoder:(NSCoder *)coder{
	if(self = [super init]){
		[self setStaffs:[coder decodeObjectForKey:@"staffs"]];
		NSEnumerator *staffEnum = [staffs objectEnumerator];
		id staff;
		while(staff = [staffEnum nextObject]){
			[staff setSong:self];
		}
		[self setTempoData:[coder decodeObjectForKey:@"tempoData"]];
		[self refreshTimeSigs];
		NSArray *_sigs = [coder decodeObjectForKey:@"timeSigs"];
		NSEnumerator *sigsEnum = [_sigs objectEnumerator];
		id sig;
		int index = 0;
		while(sig = [sigsEnum nextObject]){
			if(![sig isKindOfClass:[NSNull class]]){
				[self setTimeSignature:[TimeSignature timeSignatureWithTop:[sig getTop] bottom:[sig getBottom]] atIndex:index];
			}
			index++;
		}
	}
	return self;
}

- (void)dealloc{
	[staffs release];
	staffs = nil;
	[super dealloc];
}

@end
