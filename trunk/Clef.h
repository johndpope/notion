//
//  Clef.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Clef : NSObject {
	int pitchOffset;
	int octaveOffset;
}

- (id)initWithPitchOffset:(int)_pitchOff withOctaveOffset:(int)_octOff;

+ (Clef *)trebleClef;
+ (Clef *)bassClef;
+ (Clef *)getClefAfter:(Clef *)clef;

- (int)getPositionForPitch:(int)pitch withOctave:(int)octave;
- (int)getPitchForPosition:(int)position;
- (int)getOctaveForPosition:(int)position;
- (int)getTranspositionFrom:(Clef *)clef;

@end
