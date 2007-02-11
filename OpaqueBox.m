//
//  OpaqueBox.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 2/10/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import "OpaqueBox.h"
#import "NSBezierPathAdditions.h"

@implementation OpaqueBox

- (void)drawRect:(NSRect)rect{
	NSRect bounds = NSInsetRect([self borderRect], 4.0, 4.0);
	[NSGraphicsContext saveGraphicsState];
	[[NSColor colorWithDeviceRed:0.7 green:0.7 blue:0.7 alpha:0.9] set];
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowBlurRadius:3.0];
	[shadow setShadowOffset:NSMakeSize(3.0, -3.0)];
	[shadow setShadowColor:[NSColor colorWithDeviceRed:0.75 green:0.75 blue:0.75 alpha:0.9]];
	[shadow set];
	[[NSBezierPath bezierPathWithRoundedRect:bounds cornerRadius:10.0] fill];
	[NSGraphicsContext restoreGraphicsState];
}

- (void)setHidden:(BOOL)hidden{
	if(isMidHide){
		[super setHidden:hidden];
	} else {
		isMidHide = YES;
		[self setHidden:hidden withFade:YES blocking:YES];
		isMidHide = NO;
	}
}

@end
