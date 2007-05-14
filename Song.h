//
//  Song.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>
@class Staff;
@class TimeSignature;
@class MusicDocument;
@class Measure;
@class NoteBase;

@interface Song : NSObject <NSCoding>{
	MusicDocument *doc;
	
	NSMutableArray *staffs;
	NSMutableArray *tempoData;
	NSMutableArray *timeSigs;
	NSMutableArray *repeats;
	
	NSTimer *musicPlayerPoll;
	double playerPosition, playerOffset, playerEnd;
	MusicPlayer musicPlayer;
	MusicSequence musicSequence;
	
	MusicPlayer feedbackPlayer;
	MusicSequence feedbackSequence;
	MusicTrack feedbackTrack;
}

- (id)initWithDocument:(MusicDocument *)_doc;
- (id)initFromMIDI:(NSData *)data withDocument:(MusicDocument *)_doc;

- (MusicDocument *)document;
- (void)setDocument:(MusicDocument *)_document;
- (NSUndoManager *)undoManager;

- (NSMutableArray *)staffs;

- (void)setStaffs:(NSMutableArray *)_staffs;
- (Staff *)addStaff;
- (void)removeStaff:(Staff *)staff;

- (double)getPlayerPosition;
- (double)getPlayerEnd;

- (int)getNumMeasures;

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
- (void)timeSigChangedAtIndex:(int)measureIndex top:(int)top bottom:(int)bottom secondTop:(int)secondTop secondBottom:(int)secondBottom;
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
- (void)playToEndpoint:(MIDIEndpointRef)endpoint notesToPlay:(id)selection;
- (void)playFeedbackNote:(NoteBase *)note atPosition:(float)pos inMeasure:(Measure *)measure 
		withExistingNote:(NoteBase *)existingNote toEndpoint:(MIDIEndpointRef)endpoint;
- (void)stopPlaying;

- (NSData *)asMIDIData;

@end
