//
//  StaffVerticalRuler.h
//  Music Editor
//
//  Created by Konstantine Prevas on 6/5/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StaffVerticalRuler : NSView {
	NSMutableDictionary *trackingRects;
}

- (NSTrackingRectTag)addTrackingRect:(NSRect)aRect owner:(id)userObject 
	userData:(void *)userData assumeInside:(BOOL)flag forView:(NSView *)view;

@end
