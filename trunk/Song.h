//
//  Song.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreMidi/CoreMidi.h>
@class Staff;
@class TimeSignature;
@class MusicDocument;
@class Measure;

@interface Song : NSObject <NSCoding>{
	MusicDocument *doc;
	
	NSMutableArray *staffs;
	NSMutableArray *tempoData;
	NSMutableArray *timeSigs;
	NSMutableArray *repeats;
	
	NSTimer *musicPlayerPoll;
	double playerPosition;
	double playerEnd;
}

- (id)initWithDocument:(MusicDocument *)_doc;

- (MusicDocument *)document;
- (NSUndoManager *)undoManager;

- (NSMutableArray *)staffs;

- (void)setStaffs:(NSMutableArray *)_staffs;
- (Staff *)addStaff;
- (void)removeStaff:(Staff *)staff;

- (double)getPlayerPosition;

- (NSMutableArray *)tempoData;
- (void)setTempoData:(NSMutableArray *)_tempoData;
- (float)getTempoAt:(int)measureIndex;
- (void)refreshTempoData;

- (NSMutableArray *)timeSigs;
- (void)setTimeSigs:(NSMutableArray *)_timeSigs;
- (void)setTimeSignature:(TimeSignature *)sig atIndex:(int)measureIndex;
- (TimeSignature *)getTimeSignatureAt:(int)measureIndex;
- (TimeSignature *)getEffectiveTimeSignatureAt:(int)measureIndex;
- (void)refreshTimeSigs;
- (void)timeSigChangedAtIndex:(int)measureIndex top:(int)top bottom:(int)bottom;
- (void)timeSigDeletedAtIndex:(int)measureIndex;

- (BOOL)repeatStartsAt:(int)measureIndex;
- (BOOL)repeatEndsAt:(int)measureIndex;
- (int)numRepeatsEndingAt:(int)measureIndex;
- (BOOL)repeatIsOpenAt:(int)measureIndex;
- (void)startNewRepeatAt:(int)measureIndex;
- (void)endRepeatAt:(int)measureIndex;
- (void)setNumRepeatsEndingAt:(int)measureIndex to:(int)numRepeats;
- (void)removeEndRepeatAt:(int)measureIndex;
- (void)removeRepeatStartingAt:(int)measureIndex;

- (void)soloPressed:(BOOL)solo onStaff:(Staff *)staff;

- (void)playToEndpoint:(MIDIEndpointRef)endpoint;
- (void)stopPlaying;

@end
