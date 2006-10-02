//
//  Chord.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/30/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NoteBase.h"
@class Staff;

@interface Chord : NoteBase <NSCopying> {
	NSMutableArray *notes;
}

- (id)initWithStaff:(Staff *)_staff;
- (id)initWithStaff:(Staff *)_staff withNotes:(NSArray *)_notes;

- (NSArray *)getNotes;

- (void)addNote:(NoteBase *)note;

@end
