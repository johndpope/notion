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
#import "Measure.h"

@implementation TimeSignatureDraw

+(void)drawTimeSig:(TimeSignature *)sig inMeasure:(Measure *)measure isTarget:(BOOL)isTarget{
	NSRect bounds = [[measure getControllerClass] innerBoundsOf:measure];
	float baseY = [StaffController baseOf:[measure getStaff]];
	float lineHeight = [StaffController lineHeightOf:[measure getStaff]];
	if(sig != nil && ![sig isKindOfClass:[NSNull class]]){
		NSPoint accLoc;
		accLoc.x = bounds.origin.x + [[measure getControllerClass] timeSigAreaX:measure];
		accLoc.y = baseY - lineHeight * 18;
		NSMutableDictionary *atts = [NSMutableDictionary dictionary];
		[atts setObject:[NSFont fontWithName:@"Musicator" size:160] forKey:NSFontAttributeName];
		if(isTarget){
			[atts setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
		} else{
			[atts setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
		}
		[[NSString stringWithFormat:@"%d", [sig getBottom]] drawAtPoint:accLoc withAttributes:atts];
		accLoc.y -= lineHeight * 4;
		[[NSString stringWithFormat:@"%d", [sig getTop]] drawAtPoint:accLoc withAttributes:atts];			
		[[NSColor blackColor] set];
	} else if(isTarget){
		NSImage *sigIns = [NSImage imageNamed:@"timesig_insert.png"];
		[sigIns compositeToPoint:NSMakePoint(bounds.origin.x + [[measure getControllerClass] timeSigAreaX:measure], bounds.origin.y)
					   operation:NSCompositeSourceOver];			
	}	
}

@end
