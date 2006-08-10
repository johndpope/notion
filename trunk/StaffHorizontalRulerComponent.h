//
//  StaffHorizontalRulerComponent.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/8/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface StaffHorizontalRulerComponent : NSView {
	NSTrackingRectTag trackingRect;
	BOOL shouldFade;
	BOOL mouseIn, isHiding;
	IBOutlet NSTextField *text;
}

- (void)setShouldFade:(BOOL)_shouldFade;

@end
