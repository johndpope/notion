//
//  CompoundTimeSigController.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 1/8/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import "CompoundTimeSigController.h"
#import "TimeSignature.h"
#import "CompoundTimeSig.h"

@implementation CompoundTimeSigController

+ (float) widthOf:(TimeSignature *)timeSig{
	TimeSignature *firstSig = [timeSig firstSig], *secondSig = [timeSig secondSig];
	return [[firstSig getControllerClass] widthOf:firstSig] + [[secondSig getControllerClass] widthOf:secondSig];
}

@end
