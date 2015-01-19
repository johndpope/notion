//
//  NSView+ScaleUtilities.m
//

#import "NSView+ScaleUtilities.h"


@implementation NSView(ScaleUtilities)

const NSSize unitSize = { 1.0, 1.0 };

// This method makes the scaling of the receiver equal to the window's
// base coordinate system.
- (void) resetScaling {
	[self scaleUnitSquareToSize: [self convertSize: unitSize fromView: nil]];
}

	// This method sets the scale in absolute terms.
- (void) setScale:(NSSize) newScale {
	[self resetScaling];  // First, match our scaling to the window's coordinate system
	[self scaleUnitSquareToSize:newScale]; // Then, set the scale.
}

// This method returns the scale of the receiver's coordinate system, relative to
// the window's base coordinate system.
- (NSSize) scale {
	return [self convertSize:unitSize toView:nil];
}

@end
