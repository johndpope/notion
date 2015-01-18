//
//  NSImage+Flip.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 2/3/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import "NSImage+Flip.h"


@implementation NSImage(Flip)

-(void) drawFlippedAtPoint:(NSPoint)point{
	[self setFlipped:YES];
	[self drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[self setFlipped:NO];
}

@end
