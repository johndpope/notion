//
//  ClefDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/29/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "ClefDraw.h"
#import "Clef.h"
#import "StaffController.h"
#import "MeasureController.h"
#import "Measure.h"

@implementation ClefDraw

+(void)draw:(Clef *)clef inMeasure:(Measure *)measure isTarget:(BOOL)isTarget{
	if(clef != nil){
		NSImage *img;
		NSPoint clefLoc;
		float baseY = [StaffController baseOf:[measure getStaff]] - [StaffController innerHeightOf:[measure getStaff]];
		clefLoc.x = [[measure getControllerClass] xOf:measure] + [[measure getControllerClass] clefAreaX:measure];
		if(clef == [Clef trebleClef]){
			if(isTarget){
				img = [NSImage imageNamed:@"treble over.png"];
			} else{
				img = [NSImage imageNamed:@"treble.png"];
			}
			clefLoc.y = baseY - 17;
		} else if(clef == [Clef bassClef]){
			if(isTarget){
				img = [NSImage imageNamed:@"bass over.png"];
			} else{
				img = [NSImage imageNamed:@"bass.png"];
			}
			clefLoc.y = baseY;
		}
		[img drawFlippedAtPoint:clefLoc];
	} else if(isTarget){
		NSRect bounds = [MeasureController innerBoundsOf:measure];
		NSImage *clefIns;
		if([measure getEffectiveClef] == [Clef trebleClef]){
			clefIns = [NSImage imageNamed:@"clefins_bass.png"];
		} else{
			clefIns = [NSImage imageNamed:@"clefins_treble.png"];
		}
		[clefIns drawFlippedAtPoint:NSMakePoint(bounds.origin.x + [[measure getControllerClass] clefAreaX:measure], bounds.origin.y - [clefIns size].height)];
	}
}

@end
