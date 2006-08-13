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

@interface Song : NSObject <NSCoding>{
	NSMutableArray *staffs;
	NSMutableArray *tempoData;
	NSMutableArray *timeSigs;
}

- (NSMutableArray *)staffs;

- (void)setStaffs:(NSMutableArray *)_staffs;
- (Staff *)addStaff;
- (void)removeStaff:(Staff *)staff;

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

- (void)playToEndpoint:(MIDIEndpointRef)endpoint;

@end
