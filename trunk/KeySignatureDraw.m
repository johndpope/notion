//
//  KeySignatureDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/17/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "KeySignatureDraw.h"
#import "KeySignature.h"
#import "Measure.h"
#import "MeasureController.h"
#import "StaffController.h"
#import "ClefController.h"
#import "TimeSignatureController.h"

@implementation KeySignatureDraw

+(void)drawKeySig:(KeySignature *)sig inMeasure:(Measure *)measure isTarget:(BOOL)isTarget{
	NSRect bounds = [[measure getControllerClass] innerBoundsOf:measure];
	float baseY = [StaffController baseOf:[measure getStaff]];
	float lineHeight = [StaffController lineHeightOf:[measure getStaff]];
	if(sig != nil && ([sig getNumSharps] > 0 || [sig getNumFlats] > 0)){
		NSPoint accLoc;
		accLoc.x = bounds.origin.x + [[measure getControllerClass] keySigAreaX:measure];
		NSEnumerator *sharps = [[sig getSharpsWithClef:[measure getEffectiveClef]] objectEnumerator];
		NSNumber *sharp;
		NSImage *sharpImg;
		if(isTarget){
			sharpImg = [NSImage imageNamed:@"sharp over.png"];
		} else{
			sharpImg = [NSImage imageNamed:@"sharp.png"];
		}
		while(sharp = [sharps nextObject]){
			int sharpLoc = [sharp intValue];
			accLoc.y = baseY - lineHeight * sharpLoc + 7.0;
			[sharpImg compositeToPoint:accLoc operation:NSCompositeSourceOver];
			accLoc.x += 10.0;
		}
		NSEnumerator *flats = [[sig getFlatsWithClef:[measure getEffectiveClef]] objectEnumerator];
		NSNumber *flat;
		NSImage *flatImg;
		if(isTarget){
			flatImg = [NSImage imageNamed:@"flat over.png"];
		} else{
			flatImg = [NSImage imageNamed:@"flat.png"];
		}
		while(flat = [flats nextObject]){
			int flatLoc = [flat intValue];
			accLoc.y = baseY - lineHeight * flatLoc + 3.0;
			[flatImg compositeToPoint:accLoc operation:NSCompositeSourceOver];
			accLoc.x += 10.0;
		}
	} else if(isTarget && ![measure isShowingKeySigPanel]){
		NSImage *sigIns = [NSImage imageNamed:@"keysig_insert.png"];
		[sigIns compositeToPoint:NSMakePoint(bounds.origin.x + [[measure getControllerClass] keySigAreaX:measure], bounds.origin.y)
					   operation:NSCompositeSourceOver];			
	}	
}

@end
