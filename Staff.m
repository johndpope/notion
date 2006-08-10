//
//  Staff.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Staff.h"
#import "Measure.h"
#import "Clef.h"
#import "KeySignature.h"
#import "TimeSignature.h"

@implementation Staff

- (id)initWithSong:(Song *)_song{
	if((self = [super init])){
		Measure *firstMeasure = [[Measure alloc] initWithStaff:self];
		[firstMeasure setClef:[Clef trebleClef]];
		[firstMeasure setKeySignature:[KeySignature getSignatureWithFlats:0]];
		[firstMeasure setTimeSignature:[TimeSignature timeSignatureWithTop:4 bottom:4]];
		measures = [[NSMutableArray arrayWithObject:firstMeasure] retain];
		song = _song;
	}
	return self;
}

- (void)setSong:(Song *)_song{
	song = _song;
}

- (NSMutableArray *)getMeasures{
	return measures;
}

- (void)setMeasures:(NSMutableArray *)_measures{
	if(![measures isEqual:_measures]){
		[measures release];
		measures = [_measures retain];
	}
}

- (StaffVerticalRulerComponent *)rulerView{
	return rulerView;
}

- (IBAction)setChannel:(id)sender{
	channel = [[channelButton titleOfSelectedItem] intValue] - 1;
}

- (IBAction)deleteSelf:(id)sender{
	[song removeStaff:self];
	[rulerView removeFromSuperview];
}

- (Clef *)getClefForMeasure:(Measure *)measure{
	int index = [measures indexOfObject:measure];
	while([measure getClef] == nil){
		if(index == 0) return [Clef trebleClef];
		index--;
		measure = [measures objectAtIndex:index];
	}
	return [measure getClef];
}

- (KeySignature *)getKeySignatureForMeasure:(Measure *)measure{
	int index = [measures indexOfObject:measure];
	while([measure getKeySignature] == nil){
		if(index == 0) return [KeySignature getSignatureWithSharps:0];
		index--;
		measure = [measures objectAtIndex:index];
	}
	return [measure getKeySignature];
}

- (TimeSignature *)getTimeSignatureForMeasure:(Measure *)measure{
	int index = [measures indexOfObject:measure];
	while([measure getTimeSignature] == nil){
		if(index == 0) return [TimeSignature getSignatureWithTop:4 bottom:4];
		index--;
		measure = [measures objectAtIndex:index];
	}
	return [measure getTimeSignature];
}

- (Measure *)getLastMeasure{
	return [measures lastObject];
}

- (Measure *)getMeasureAfter:(Measure *)measure{
	int index = [measures indexOfObject:measure];
	if(index + 1 < [measures count]){
		return [measures objectAtIndex:(index + 1)];
	} else{
		measure = [[Measure alloc] initWithStaff:self];
		[measures addObject:measure];
		[song refreshTempoData];
		return measure;
	}
}

- (void)cleanEmptyMeasures{
	while([measures count] > 1 && [[measures lastObject] isEmpty]){
		Measure *measure = [measures lastObject];
		[measure keySigClose:nil];
		[measures removeLastObject];
	}
	[song refreshTempoData];
}

- (Note *)findPreviousNoteMatching:(Note *)source inMeasure:(Measure *)measure atIndex:(int)index{
	Note *note = [measure findPreviousNoteMatching:source atIndex:index];
	while(note == nil && measure != [measures objectAtIndex:0]){
		measure = [measures objectAtIndex:([measures indexOfObject:measure]-1)];
		note = [measure findPreviousNoteMatching:source atIndex:NSNotFound];
	}
	return note;
}

- (void)toggleClefAtMeasure:(Measure *)measure{
	Clef *oldClef = [measure getClef];
	if(oldClef != nil && measure != [measures objectAtIndex:0]){
		[measure setClef:nil];
	} else{
		oldClef = [self getClefForMeasure:measure];
		[measure setClef:[Clef getClefAfter:oldClef]];
	}
	Clef *newClef = [self getClefForMeasure:measure];
	int transposeAmount = [newClef getTranspositionFrom:oldClef];
	int index = [measures indexOfObject:measure] + 1;
	[measure transposeBy:transposeAmount];
	if(index < [measures count]){
		while(index < [measures count]){
			measure = [measures objectAtIndex:index++];
			if([measure getClef] != nil) break;
			[measure transposeBy:transposeAmount];
		}
	}
}

- (void)addTrackToMIDISequence:(MusicSequence *)musicSequence{
	MusicTrack musicTrack;
	if (MusicSequenceNewTrack(*musicSequence, &musicTrack) != noErr) {
		NSLog(@"Cannot create music track.");
		return;
	}
  
	NSEnumerator *measureEnum = [measures objectEnumerator];
	id measure;
	float pos = 0.0;
	while(measure = [measureEnum nextObject]){
		pos += [measure addToMIDITrack:&musicTrack atPosition:pos
				onChannel:channel];
	}

	MIDIMetaEvent metaEvent = { 0x2f, 0, 0, 0, 0, { 0 } };
	if (MusicTrackNewMetaEvent(musicTrack, 13.0, &metaEvent) != noErr) {
		NSLog(@"Cannot add end of track meta event to track.");
		return;
	}

}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:measures forKey:@"measures"];
	[coder encodeInt:channel forKey:@"channel"];
}

- (id)initWithCoder:(NSCoder *)coder{
	if(self = [super init]){
		[self setMeasures:[coder decodeObjectForKey:@"measures"]];
		channel = [coder decodeIntForKey:@"channel"];
	}
	return self;
}

- (void)dealloc{
	[super dealloc];
	[measures release];
	measures = nil;
	song = nil;
}

@end
