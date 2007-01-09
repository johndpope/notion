//
//  TimeSignatureDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/17/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "TimeSignatureDraw.h"
#import "MeasureController.h"
#import "StaffController.h"
#import "ClefController.h"
#import "TimeSignature.h"
#import "CompoundTimeSig.h"
#import "Measure.h"

static NSMutableDictionary *timeSigAttrs = nil;

@implementation TimeSignatureDraw

+(NSMutableDictionary *)timeSigStringAttrs{
	if(timeSigAttrs == nil){
		timeSigAttrs = [[NSMutableDictionary dictionary] retain];
		[timeSigAttrs setObject:[NSFont fontWithName:@"Musicator" size:160] forKey:NSFontAttributeName];			
	}
	return timeSigAttrs;
}

+(void)drawTimeSig:(TimeSignature *)sig inMeasure:(Measure *)measure isTarget:(BOOL)isTarget xOffset:(float)xOffset{
	NSRect bounds = [[measure getControllerClass] innerBoundsOf:measure];
	float baseY = [StaffController baseOf:[measure getStaff]];
	float lineHeight = [StaffController lineHeightOf:[measure getStaff]];
	if(sig != nil && ![sig isKindOfClass:[NSNull class]]){
		NSPoint accLoc;
		accLoc.x = bounds.origin.x + [[measure getControllerClass] timeSigAreaX:measure] + xOffset;
		accLoc.y = baseY - lineHeight * 18;
		NSMutableDictionary *attrs = [self timeSigStringAttrs];
		if(isTarget){
			[attrs setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
		} else{
			[attrs setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
		}
		[[NSString stringWithFormat:@"%d", [sig getBottom]] drawAtPoint:accLoc withAttributes:attrs];
		accLoc.y -= lineHeight * 4;
		[[NSString stringWithFormat:@"%d", [sig getTop]] drawAtPoint:accLoc withAttributes:attrs];			
		[[NSColor blackColor] set];
	} else if(isTarget){
		NSImage *sigIns = [NSImage imageNamed:@"timesig_insert.png"];
		[sigIns compositeToPoint:NSMakePoint(bounds.origin.x + [[measure getControllerClass] timeSigAreaX:measure], bounds.origin.y)
					   operation:NSCompositeSourceOver];			
	}	
}

+(void)drawTimeSig:(TimeSignature *)sig inMeasure:(Measure *)measure isTarget:(BOOL)isTarget{
	if([sig isKindOfClass:[CompoundTimeSig class]]){
		[[sig getViewClass] drawTimeSig:sig inMeasure:measure isTarget:isTarget];
		return;
	}
	[self drawTimeSig:sig inMeasure:measure isTarget:isTarget xOffset:0];
}

@end
