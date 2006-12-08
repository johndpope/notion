//
//  ScoreView.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/3/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Song;
@class MEWindowController;

@interface ScoreView : NSView {
	MEWindowController *controller;
	Song *song;
	
	NSPoint mouseLocation;
	id clickTarget;
	BOOL dragging;
	id mouseOver;

	ATSFontContainerRef container;
}

- (void)setController:(MEWindowController *)_controller;

- (Song *)getSong;
- (void)setSong:(Song*)song;

- (void)drawRect:(NSRect)rect;
- (BOOL)isOpaque;

- (NSRect)calculateBounds;

@end
