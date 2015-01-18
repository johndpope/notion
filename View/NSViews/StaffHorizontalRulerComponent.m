//
//  StaffHorizontalRulerComponent.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/8/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "StaffHorizontalRulerComponent.h"


@implementation StaffHorizontalRulerComponent

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
	[[self window] setAcceptsMouseMovedEvents:YES];
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(windowDidUpdate:) name:NSWindowDidUpdateNotification
		object:nil];
}

- (void)setHidden:(BOOL)hidden{
	isHiding = hidden;
	[super setHidden:hidden];
}

- (BOOL)isTextFieldActive{
	if([[[self window] firstResponder] isKindOfClass:[NSTextView class]] &&
		[[self window] fieldEditor:NO forObject:nil] != nil){
			return [[[self window] firstResponder] delegate] == text;
	}
	return NO;
}

- (void)windowDidUpdate:(NSNotification *)notification{
	if(!isHiding && !mouseIn && shouldFade && ![self isTextFieldActive]){
		isHiding = YES;
		[self setHidden:YES withFade:YES blocking:NO];	
	}
}

- (void)viewDidMoveToWindow{
	trackingRect = [[self superview] addTrackingRect:[self visibleRect]
		owner:self userData:nil assumeInside:NO forView:self];
}

- (void)viewWillMoveToWindow:(NSWindow *)win{
	if(!win && [self window]){
		[[self superview] removeTrackingRect:trackingRect];
	}
	[super viewWillMoveToWindow:win];
}

- (void)resetCursorRects{
	[super resetCursorRects];
	[[self superview] removeTrackingRect:trackingRect];
	trackingRect = [[self superview] addTrackingRect:[self frame]
		owner:self userData:nil assumeInside:NO forView:self];
}

- (void)setShouldFade:(BOOL)_shouldFade{
	shouldFade = _shouldFade;
}

- (void)mouseEntered:(NSEvent *)theEvent{
	if(shouldFade){
		[self setHidden:NO withFade:YES blocking:NO];
	}
	mouseIn = YES;
}

- (void)mouseExited:(NSEvent *)theEvent{
	if(!isHiding && shouldFade && ![self isTextFieldActive]){
		isHiding = YES;
		[self setHidden:YES withFade:YES blocking:NO];	
	}
	mouseIn = NO;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
}

- (void)dealloc{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self];
	[[self superview] removeTrackingRect:trackingRect];
	[super dealloc];
}

@end
