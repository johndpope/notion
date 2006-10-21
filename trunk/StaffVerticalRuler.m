//
//  StaffVerticalRuler.m
//  Music Editor
//
//  Created by Konstantine Prevas on 6/5/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "StaffVerticalRuler.h"


@implementation StaffVerticalRuler

- (void)awakeFromNib{
	trackingRects = [[NSMutableDictionary dictionary] retain];
}

- (BOOL) isFlipped{
	return YES;
}

- (NSTrackingRectTag)addTrackingRect:(NSRect)aRect owner:(id)userObject 
	userData:(void *)userData assumeInside:(BOOL)flag forView:(NSView *)view{
	NSTrackingRectTag rect = [self addTrackingRect:aRect owner:userObject userData:userData assumeInside:flag];
	[trackingRects setObject:view forKey:[NSNumber numberWithInt:rect]];
	return rect;
}

- (void)mouseEntered:(NSEvent *)theEvent{
	NSView *view = [trackingRects objectForKey:[NSNumber numberWithInt:[theEvent trackingNumber]]];
	[view mouseEntered:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent{
	NSView *view = [trackingRects objectForKey:[NSNumber numberWithInt:[theEvent trackingNumber]]];
	[view mouseExited:theEvent];
}



@end
