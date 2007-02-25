//
//  Drum.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 2/24/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Drum : NSObject {
	int pitch, octave;
	NSString *name, *shortName;
}

- (id) initWithPitch:(int)_pitch octave:(int)_octave name:(NSString *)_name shortName:(NSString *)_shortName;

- (int) octave;
- (int) pitch;
- (NSString *)name;
- (NSString *)shortName;

@end
