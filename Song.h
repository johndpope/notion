//
//  Song.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/4/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreMidi/CoreMidi.h>
@class Staff;

@interface Song : NSObject {
	NSMutableArray *staffs;
	NSMutableArray *tempoData;
}

- (NSMutableArray *)staffs;

- (void)setStaffs:(NSMutableArray *)_staffs;
- (Staff *)addStaff;

- (NSMutableArray *)tempoData;
- (float)getTempoAt:(int)measureIndex;

- (void)playToEndpoint:(MIDIEndpointRef)endpoint;

@end
