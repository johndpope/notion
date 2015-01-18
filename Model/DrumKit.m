//
//  DrumKit.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 12/3/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "DrumKit.h"
#import "Drum.h"
#import <Chomp/Chomp.h>

static DrumKit *standardKit;
static NSArray *allDrums;

@implementation DrumKit

- (id) initWithDrums:(NSArray *)_drums{
	if(self = [super init]){
		drums = [[NSMutableArray arrayWithArray:_drums] retain];
	}
	return self;	
}

- (void)sendChangeNotification{
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"modelChanged" object:self]];
}

- (BOOL)positionIsValid:(int)position{
	return (position >= 0) && (position < [drums count]);
}

- (int)getPositionForPitch:(int)pitch withOctave:(int)octave{
	int i;
	for(i = 0; i < [drums count]; i++){
		if([[drums objectAtIndex:([drums count] - i - 1)] pitch] == pitch &&
		   [[drums objectAtIndex:([drums count] - i - 1)] octave] == octave){
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
	if(position >= [drums count]){
		position = [drums count] - 1;
	}
	return [[drums objectAtIndex:([drums count] - position - 1)] pitch];
}

- (int)getOctaveForPosition:(int)position{
	if(position < 0){
		position == 0;
	}
	if(position >= [drums count]){
		position = [drums count] - 1;
	}
	return [[drums objectAtIndex:([drums count] - position - 1)] octave];
}

- (int)getTranspositionFrom:(Clef *)clef{
	return 0;
}

- (NSString *)nameAt:(int)position{
	return [[drums objectAtIndex:([drums count] - position - 1)] shortName];
}

- (NSString *)lilypondStringForPitch:(int)pitch octave:(int)octave{
	NSEnumerator *drumsEnum = [drums objectEnumerator];
	id drum;
	while(drum = [drumsEnum nextObject]){
		if([drum pitch] == pitch && [drum octave] == octave){
			return [drum lilypondString];
		}
	}
}

- (NSString *)musicXMLStringForPitch:(int)pitch octave:(int)octave{
	NSEnumerator *drumsEnum = [drums objectEnumerator];
	id drum;
	while(drum = [drumsEnum nextObject]){
		if([drum pitch] == pitch && [drum octave] == octave){
			return [drum musicXMLString];
		}
	}
}

- (void)appendMusicXMLHeaderToString:(NSMutableString *)string{
	[[drums do] appendMusicXMLHeaderToString:string];
}

- (NSMutableArray *)drums{
	return drums;
}

- (void)setDrums:(NSMutableArray *)_drums{
	[[[staff undoManager] prepareWithInvocationTarget:self] setDrums:drums];
	[[staff undoManager] setActionName:@"editing drum kit"];
	if(![_drums isEqualToArray:drums]){
		[drums release];
		drums = [_drums retain];
		[self sendChangeNotification];
	}
}

- (Staff *)staff{
	return staff;
}
- (void)setStaff:(Staff *)_staff{
	staff = _staff;
}

- (NSWindow *)editDialog{
	return editDialog;
}

- (IBAction)closeDialog:(id)sender{
	[NSApp endSheet:editDialog];
	[[staff undoManager] endUndoGrouping];
}

- (IBAction)cancelDialog:(id)sender{
	[self closeDialog:sender];
	[[staff undoManager] undo];
}

- (void)endEditDialog{
	[editDialog orderOut:self];
	[self sendChangeNotification];
}

- (IBAction)import:(id)sender{
	NSOpenPanel *open = [NSOpenPanel openPanel];
	[open setTitle:@"Import Drum Kit"];
	[open setAllowsMultipleSelection:NO];
	if([open runModalForTypes:[NSArray arrayWithObject:@"ssd"]] == NSOKButton){
		NSString *file = [[open filenames] objectAtIndex:0];
		[self setDrums:[NSKeyedUnarchiver unarchiveObjectWithFile:file]];
	}
}
- (IBAction)export:(id)sender{
	NSSavePanel *save = [NSSavePanel savePanel];
	[save setTitle:@"Export Drum Kit"];
	[save setRequiredFileType:@"ssd"];
	if([save runModal] == NSOKButton){
		NSString *file = [save filename];
		[NSKeyedArchiver archiveRootObject:drums toFile:file];
	}
}

+ (DrumKit *)standardKit{
	if(standardKit == nil){
		standardKit = [[DrumKit alloc] initWithDrums:[NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"stdDrums" ofType:@"dat"]]];
	}
	return standardKit;
}

- (NSArray *)allDrums{
	if(allDrums == nil){
		allDrums = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"allDrums" ofType:@"dat"]];
	}
	return allDrums;
}

- (id)copyWithZone:(NSZone *)zone{
	return [[DrumKit allocWithZone:zone] initWithDrums:[NSArray arrayWithArray:drums]];
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:drums forKey:@"drums"];
}

- (id)initWithCoder:(NSCoder *)coder{
	if(self = [super init]){
		drums = [coder decodeObjectForKey:@"drums"];
		// support old-style
		NSArray *pitches = [coder decodeObjectForKey:@"pitches"];
		NSArray *octaves = [coder decodeObjectForKey:@"octaves"];
		NSArray *names = [coder decodeObjectForKey:@"names"];
		if(pitches != nil){
			[drums release];
			drums = [[NSMutableArray array] retain];
			NSEnumerator *pitchEnum = [pitches objectEnumerator];
			NSEnumerator *octaveEnum = [octaves objectEnumerator];
			NSEnumerator *nameEnum = [names objectEnumerator];
			id pitch, octave, name;
			while(pitch = [pitchEnum nextObject]){
				octave = [octaveEnum nextObject];
				name = [nameEnum nextObject];
				[drums addObject:[[[Drum alloc] initWithPitch:[pitch intValue] octave:[octave intValue] name:name shortName:name] autorelease]];
			}
		}
	}
	return self;
}

- (void) dealloc {
	[drums release];
	drums = nil;
	[super dealloc];
}


@end
