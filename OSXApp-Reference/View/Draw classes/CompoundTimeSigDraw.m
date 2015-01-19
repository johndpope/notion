//
//  CompoundTimeSigDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 1/8/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import "CompoundTimeSigDraw.h"
#import "CompoundTimeSig.h"
#import "TimeSignatureController.h"
#import "TimeSignatureDraw.h"

@implementation CompoundTimeSigDraw

+(void)drawTimeSig:(TimeSignature *)sig inMeasure:(Measure *)measure isTarget:(BOOL)isTarget{
	[[[sig firstSig] getViewClass] drawTimeSig:[sig firstSig] inMeasure:measure isTarget:isTarget xOffset:0];
	[[[sig secondSig] getViewClass] drawTimeSig:[sig secondSig] inMeasure:measure isTarget:isTarget 
										xOffset:[[[sig firstSig] getControllerClass] widthOf:[sig firstSig]]];
}

@end
