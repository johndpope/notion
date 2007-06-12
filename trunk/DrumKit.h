//
//  DrumKit.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 12/3/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Clef.h"
@class Staff;

@interface DrumKit : Clef {
	NSMutableArray *drums;
	Staff *staff;
	
	IBOutlet NSWindow *editDialog;
}

- (id) initWithPitches:(NSArray *)_pitches octaves:(NSArray *)_octaves names:(NSArray *)_names;

- (NSString *)nameAt:(int)position;

- (NSArray *)allDrums;

- (Staff *)staff;
- (void)setStaff:(Staff *)_staff;

- (NSMutableArray *)drums;
- (void)setDrums:(NSMutableArray *)_names;

- (NSWindow *)editDialog;
- (IBAction)closeDialog:(id)sender;
- (IBAction)cancelDialog:(id)sender;

- (IBAction)import:(id)sender;
- (IBAction)export:(id)sender;

- (void)appendMusicXMLHeaderToString:(NSMutableString *)string;
- (NSString *)musicXMLStringForPitch:(int)pitch octave:(int)octave;

+ (DrumKit *)standardKit;

@end
