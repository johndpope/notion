//
//  DrumKit.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 12/3/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Clef.h"


@interface DrumKit : Clef {
	NSMutableArray *pitches;
	NSMutableArray *octaves;
	NSMutableArray *names;
}

- (id) initWithPitches:(NSArray *)_pitches octaves:(NSArray *)_octaves names:(NSArray *)_names;

- (NSString *)nameAt:(int)position;

+ (DrumKit *)standardKit;

@end
