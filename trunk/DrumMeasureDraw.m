//
//  DrumMeasureDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 11/26/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "DrumMeasureDraw.h"
#import "MeasureController.h"
#import "TimeSignatureDraw.h"
#import "TimeSigTarget.h"
#import "MEWindowController.h"

@implementation DrumMeasureDraw

+(void)drawClef:(Clef *)clef inMeasure:(Measure *)measure isTarget:(BOOL)isTarget{
	// don't draw clef for drum measures
}

+(void)drawKeySig:(KeySignature *)sig inMeasure:(Measure *)measure isTarget:(BOOL)isTarget{
	// don't draw key signature for drum measures
}

@end
