//
//  KeySignature.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KeySignature : NSObject {
	int pitches[7];
	int sharps, flats;
}

+ (id)getMajorSignatureAtIndexFromA:(int)index;
+ (id)getMinorSignatureAtIndexFromA:(int)index;
+ (id)getSignatureWithSharps:(int)sharps;
+ (id)getSignatureWithFlats:(int)flats;

- (id)initWithPitches:(int *)_pitches sharps:(int)_sharps flats:(int)_flats;

- (int)getPitchAtPosition:(int)position;
- (int)getAccidentalAtPosition:(int)position;

- (int)getNumSharps;
- (int)getNumFlats;
- (NSArray *)getSharps;
- (NSArray *)getFlats;

@end
