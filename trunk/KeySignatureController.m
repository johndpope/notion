//
//  KeySignatureController.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "KeySignatureController.h"
#import "KeySignature.h"
#import "Measure.h"

@implementation KeySignatureController

+ (float) isolatedWidthOf:(KeySignature *)keySig inMeasure:(Measure *)measure{
	if(keySig == nil){
		return 10.0;
	}
	int numSymbols = [keySig getNumSharps] + [keySig getNumFlats];
	if(numSymbols == 0){
		Measure *last = [measure getPreviousMeasureWithKeySignature];
		if(last != nil){
			return [self isolatedWidthOf:[last getKeySignature] inMeasure:last];
		} else {
			return 10.0;
		}
	}
	return numSymbols * 10.0;	
}

+ (float) widthOf:(KeySignature *)keySig inMeasure:(Measure *)measure{
	float width = [self isolatedWidthOf:keySig inMeasure:measure];
	int index = [[[measure getStaff] getMeasures] indexOfObject:measure];
	NSEnumerator *staffs = [[[[measure getStaff] getSong] staffs] objectEnumerator];
	id staff;
	while(staff = [staffs nextObject]){
		Measure *otherMeasure = [staff getMeasureAtIndex:index];
		if(otherMeasure != self){
			float otherWidth = [self isolatedWidthOf:[otherMeasure getKeySignature] inMeasure:otherMeasure];
			if(otherWidth > width){
				width = otherWidth;
			}
		}
	}
	return width;
}

+ (void)handleMouseClick:(NSEvent *)event at:(NSPoint)location on:(KeySigTarget *)sig mode:(NSDictionary *)mode view:(ScoreView *)view{
	[view showKeySigPanelFor:[sig measure]];
}

+ (BOOL)handleKeyPress:(NSEvent *)event at:(NSPoint)location on:(KeySigTarget *)sig mode:(NSDictionary *)mode view:(ScoreView *)view{
	if([[event characters] rangeOfString:[NSString stringWithFormat:@"%C", NSDeleteCharacter]].location != NSNotFound){
		[[[sig measure] undoManager] setActionName:@"deleting key signature"];
		[[sig measure] keySigDelete];
		return YES;
	}
	return NO;
}

@end
