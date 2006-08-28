//
//  KeySignature.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/16/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KeySignature : NSObject {
	int pitches[7];
	int sharps, flats;
	BOOL minor;
}

+ (id)getMajorSignatureAtIndexFromA:(int)index;
+ (id)getMinorSignatureAtIndexFromA:(int)index;
+ (id)getSignatureWithSharps:(int)sharps minor:(BOOL)_minor;
+ (id)getSignatureWithFlats:(int)flats minor:(BOOL)_minor;

- (id)initWithPitches:(int *)_pitches sharps:(int)_sharps flats:(int)_flats minor:(BOOL)_minor;

- (int)getPitchAtPosition:(int)position;
- (int)getAccidentalAtPosition:(int)position;

- (int)getNumSharps;
- (int)getNumFlats;
- (NSArray *)getSharps;
- (NSArray *)getFlats;

- (int)getIndexFromA;
- (BOOL)isMinor;	

@end
