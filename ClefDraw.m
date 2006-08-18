//
//  ClefDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/29/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "ClefDraw.h"
#import "Clef.h"

@implementation ClefDraw

+(void)draw:(Clef *)clef atX:(NSNumber *)x base:(NSNumber *)baseY highlighted:(BOOL)highlighted{
	NSImage *img;
	NSPoint clefLoc;
	clefLoc.x = [x floatValue];
	if(clef == [Clef trebleClef]){
		if(highlighted){
			img = [NSImage imageNamed:@"treble over.png"];
		} else{
			img = [NSImage imageNamed:@"treble.png"];
		}
		clefLoc.y = [baseY floatValue] + 20;
	} else if(clef == [Clef bassClef]){
		if(highlighted){
			img = [NSImage imageNamed:@"bass over.png"];
		} else{
			img = [NSImage imageNamed:@"bass.png"];
		}
		clefLoc.y = [baseY floatValue] - 7;
	}
	[img compositeToPoint:clefLoc operation:NSCompositeSourceOver];
}

@end
