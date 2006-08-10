//
//  Song.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/4/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Song.h"
#import "Staff.h"
#import "Measure.h"
#import "TempoData.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation Song

- (id)init{
	if((self = [super init])){
		tempoData = [[NSMutableArray arrayWithObject:[[TempoData alloc] initWithTempo:120]] retain];
		staffs = [[NSMutableArray arrayWithObject:[[Staff alloc] initWithSong:self]] retain];
	}
	return self;
}

- (NSMutableArray *)staffs{
	return staffs;
}

- (void)setStaffs:(NSMutableArray *)_staffs{
	[self willChangeValueForKey:@"staffs"];
	if(![staffs isEqual:_staffs]){
		[staffs release];
		staffs = [_staffs retain];
	}
	[self didChangeValueForKey:@"staffs"];
}

- (Staff *)addStaff{
	Staff *staff = [[Staff alloc] initWithSong:self];
	[staffs addObject:staff];
	return staff;
}

- (void)removeStaff:(Staff *)staff{
	[self willChangeValueForKey:@"staffs"];
	[staffs removeObject:staff];
	if([staffs count] == 0){
		[self addStaff];
	}
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
	}
	return self;
}

- (void)dealloc{
	[super dealloc];
	[staffs release];
	staffs = nil;
}

@end
