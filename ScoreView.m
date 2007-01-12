//
//  ScoreView.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/3/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "ScoreView.h"
#import "MEWindowController.h"
#import "ScoreController.h"
#import "StaffController.h"
#import "MeasureController.h"
#import "NoteController.h"
#import "Song.h"
#import "Staff.h"
#import "TimeSignature.h"
#import "NoteDraw.h"
#import "Repeat.h"

@implementation ScoreView

- (void)setController:(MEWindowController *)_controller{
	if(![controller isEqual:_controller]){
		[controller release];
		controller = [_controller retain];
	}
}

- (Song *)getSong{
	return song;
}

- (void)setSong:(Song *)_song {
	if(![song isEqual:_song]){
		[song release];
		song = [_song retain];
		[self setFrameSize:[self calculateBounds].size];
		[self setNeedsDisplay:YES];
	}
}

- (id)selection{
	return selection;
}

- (void)setSelection:(id)_selection{
	if(![selection isEqual:_selection]){
		[selection release];
		selection = [_selection retain];
	}
}

- (NSRect)calculateBounds{
	NSRect bounds;
	bounds.origin.x = 0;
	bounds.origin.y = 0;
	bounds.size.width = 0;
	bounds.size.height = 0;
	NSEnumerator *staffs = [[song staffs] objectEnumerator];
	id staff;
	while(staff = [staffs nextObject]){
		int width = [StaffController widthOf:staff];
		bounds.size.height += [StaffController heightOf:staff] + [ScoreController staffSpacing];
		bounds.size.width = (bounds.size.width < width) ? width : bounds.size.width;
	}
	bounds.size.width += 5 * [ScoreController xInset];
	bounds.size.height += 2 * [ScoreController yInset];
	NSEnumerator *subviews = [[self subviews] objectEnumerator];
	id subview;
	while(subview = [subviews nextObject]){
		bounds = NSUnionRect(bounds, [subview frame]);
	}
	return bounds;
}

- (void)loadLocalFonts{
	NSString *fontsFolder;    
	if ((fontsFolder = [[NSBundle mainBundle] resourcePath])) {
		NSURL *fontsURL;
		if ((fontsURL = [NSURL fileURLWithPath:fontsFolder])) {
			FSRef fsRef;
			FSSpec fsSpec;
			(void)CFURLGetFSRef((CFURLRef)fontsURL, &fsRef);
			if (FSGetCatalogInfo(&fsRef, kFSCatInfoNone, NULL, NULL, &fsSpec, NULL) == noErr) {
				OSStatus err = ATSFontActivateFromFileSpecification(&fsSpec, kATSFontContextLocal, kATSFontFormatUnspecified,
																	NULL, kATSOptionFlagsDefault, &container);
				ATSFontRef fontRefs[100];
				ItemCount  fontCount;
				err = ATSFontFindFromContainer(container, kATSOptionFlagsDefault, 100, fontRefs, &fontCount );
				
				if( err != noErr || fontCount < 1 )
					return;
				
				NSString *fontName;
				err = ATSFontGetPostScriptName(fontRefs[0], kATSOptionFlagsDefault, &fontName);
			}
		}
	}
}

- (void) awakeFromNib{
	[[self window] setAcceptsMouseMovedEvents:true];
	[self loadLocalFonts];
}

- (void)drawPlayerPosition {
	double playerPosition = [song getPlayerPosition];
	if(playerPosition >= 0){
		float maxX = 0, minX = MAXFLOAT;
		NSArray *playingNotes = [ScoreController notesAtBeats:playerPosition inSong:song];
		NSMutableArray *playingMeasures = [NSMutableArray arrayWithCapacity:[playingNotes count]];
		NSEnumerator *notesEnum = [playingNotes objectEnumerator];
		id note;
		while(note = [notesEnum nextObject]){
			Measure *measure = [[note getStaff] getMeasureContainingNote:note];
			[playingMeasures addObject:measure];
			[[note getViewClass] draw:note inMeasure:measure atIndex:[[measure getNotes] indexOfObject:note] target:note selection:nil];
			float noteX = [[note getControllerClass] xOf:note];
			if(noteX > maxX){
				maxX = noteX;
			}
			if(noteX < minX){
				minX = noteX;
			}
		}
		
		float positionInMeasure = 3.0 * playerPosition / 4;
		int index;
		int repeatCount = 1;
		for(index = 0; index < [song getNumMeasures] && positionInMeasure >= [[song getEffectiveTimeSignatureAt:index] getMeasureDuration]; index++){
			positionInMeasure -= [[song getEffectiveTimeSignatureAt:index] getMeasureDuration];
			Repeat *repeat = [song repeatEndingAt:index];
			if(repeat != nil){
				if(repeatCount < [repeat numRepeats]){
					repeatCount++;
					index = [repeat startMeasure] - 1;					
				} else {
					repeatCount = 1;
				}
			}
		}
		if(index < [song getNumMeasures] && [playingMeasures count] > 0){
			NoteBase *closestBefore = nil, *closestAfter = nil;
			float distBefore = MAXFLOAT, distAfter = MAXFLOAT;
			NSEnumerator *measuresEnum = [playingMeasures objectEnumerator];
			id measure;
			while(measure = [measuresEnum nextObject]){
				NoteBase *thisBefore = [measure getClosestNoteBefore:positionInMeasure];
				float thisBeforeDist = positionInMeasure - [measure getNoteStartDuration:thisBefore];
				if(thisBeforeDist < distBefore){
					distBefore = thisBeforeDist;
					closestBefore = thisBefore;
				}
				NoteBase *thisAfter = [measure getClosestNoteAfter:positionInMeasure];
				if(thisAfter != nil){
					float thisAfterDist = [measure getNoteStartDuration:thisAfter] - positionInMeasure;
					if(thisAfterDist < distAfter){
						distAfter = thisAfterDist;
						closestAfter = thisAfter;
					}
				}
			}
			float beforePos = [[closestBefore getControllerClass] xOf:closestBefore];
			float afterPos;
			if(closestAfter != nil){
				afterPos = [[closestAfter getControllerClass] xOf:closestAfter];
			} else {
				Measure *playingMeasure = [playingMeasures objectAtIndex:0];
				NSRect bounds = [[playingMeasure getControllerClass] boundsOf:playingMeasure];
				afterPos = bounds.origin.x + bounds.size.width;
				distAfter = [[playingMeasure getEffectiveTimeSignature] getMeasureDuration] - positionInMeasure;
			}
			float pos = beforePos + (afterPos - beforePos) * (distBefore / (distBefore + distAfter));
			
			[[NSColor redColor] set];
			[NSBezierPath setDefaultLineWidth:3.0];
			[NSBezierPath strokeLineFromPoint:NSMakePoint(pos, 0) toPoint:NSMakePoint(pos, [self bounds].size.height)];
			[NSBezierPath setDefaultLineWidth:1.0];
			[[NSColor blackColor] set];			
			
			if(pos > maxX){
				maxX = pos;
			}
			if(pos < minX){
				minX = pos;
			}
		}

		if(maxX > 0) {
			[self scrollRectToVisible:NSMakeRect(minX - 25, [[self enclosingScrollView] documentVisibleRect].origin.y, maxX - minX + 50, 0)];			
		}
	}
}

- (void)drawRect:(NSRect)rect {
	[NoteDraw resetAccidentals];
	NSEnumerator *staffs = [[song staffs] objectEnumerator];
	id staff;
	while(staff = [staffs nextObject]){
		[[staff getViewClass] draw:staff inView:self target:mouseOver targetLocation:mouseLocation selection:selection mode:[controller getMode]];
	}
	[self drawPlayerPosition];
}

- (void)showKeySigPanelFor:(Measure *)measure{
	NSView *keySigPanel = [measure getKeySigPanel];
	if([keySigPanel superview] == nil){
		[self addSubview:keySigPanel];
		[keySigPanel setFrameOrigin:[MeasureController keySigPanelLocationFor:measure]];
		[keySigPanel setHidden:NO withFade:YES blocking:NO];
	}
	if([measure isShowingTimeSigPanel]) [measure timeSigClose:nil];
	[self setNeedsDisplay:YES];
}

- (void)showTimeSigPanelFor:(Measure *)measure{
	NSView *timeSigPanel = [measure getTimeSigPanel];
	if([timeSigPanel superview] == nil){
		[self addSubview:timeSigPanel];
		[measure updateTimeSigPanel];
		[timeSigPanel setFrameOrigin:[MeasureController timeSigPanelLocationFor:measure]];
		[timeSigPanel setHidden:NO withFade:YES blocking:NO];
	}
	if([measure isShowingKeySigPanel]) [measure keySigClose:nil];
	[self setNeedsDisplay:YES];
}

- (void)showRepeatCountPanelFor:(Repeat *)repeat inMeasure:(Measure *)measure{
	NSView *countPanel = [repeat getCountPanel];
	if([countPanel superview] == nil){
		[self addSubview:countPanel];
		[repeat updateCountPanel];
		[countPanel setFrameOrigin:[MeasureController repeatPanelLocationFor:measure]];
		[countPanel setHidden:NO withFade:YES blocking:NO];
	}
	[self setNeedsDisplay:YES];
}

- (void)updateFeedback:(NSEvent *)event{
	[self setFrameSize:[self calculateBounds].size];
	if([self mouse:mouseLocation inRect:[self frame]]){
		mouseOver = [controller targetAt:mouseLocation withEvent:event];
	} else {
		mouseOver = nil;
	}
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event{
	dragStart = mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
	clickTarget = mouseOver;
	[self setFrameSize:[self calculateBounds].size];
	[self updateFeedback:event];
}

- (void)mouseUp:(NSEvent *)event{
	mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
	if(dragging){
		[controller dragged:clickTarget fromLocation:dragStart toLocation:mouseLocation withEvent:event finished:YES];
	}
	dragging = NO;
	if([mouseOver isEqual:clickTarget]){
		[controller clickedAtLocation:mouseLocation withEvent:event];		
	}
	[self setFrameSize:[self calculateBounds].size];
	[self updateFeedback:event];
}

- (void)mouseDragged:(NSEvent *)event{
	dragging = YES;
	mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
	[controller dragged:clickTarget fromLocation:dragStart toLocation:mouseLocation withEvent:event finished:NO];
	[self setFrameSize:[self calculateBounds].size];
	[self updateFeedback:event];
}

- (void)mouseMoved:(NSEvent *)event{
	mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
	[self setFrameSize:[self calculateBounds].size];
	[self updateFeedback:event];
}

- (void)keyDown:(NSEvent *)event{
	if(![controller keyPressedAtLocation:mouseLocation withEvent:event]){
		[super keyDown:event];
	}
	[self setFrameSize:[self calculateBounds].size];
	[self updateFeedback:event];
}

- (void)flagsChanged:(NSEvent *)event{
	[self updateFeedback:event];
}

- (void)cut:(id)sender{
	[self copy:sender];
	if([selection respondsToSelector:@selector(containsObject:)]){
		NSEnumerator *notes = [selection objectEnumerator];
		id note;
		while(note = [notes nextObject]){
			[[note getControllerClass] doNoteDeletion:note];
		}
		[[[controller document] undoManager] setActionName:@"cutting note"];
	} else {
		[[selection getControllerClass] doNoteDeletion:selection];
		[[[controller document] undoManager] setActionName:@"cutting notes"];
	}
}

- (void)copy:(id)sender{
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[pb declareTypes:[NSArray arrayWithObject:@"NotesPBType"] owner:self];
	NSData *data = nil;
	if([self selection] != nil){
		data = [NSKeyedArchiver archivedDataWithRootObject:selection];
	} else if(mouseOver != nil && [mouseOver respondsToSelector:@selector(encodeWithCoder:)]){
		data = [NSKeyedArchiver archivedDataWithRootObject:mouseOver];
	}
	[pb setData:data forType:@"NotesPBType"];
}

- (void)paste:(id)sender{
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	id data = [NSKeyedUnarchiver unarchiveObjectWithData:[pb dataForType:@"NotesPBType"]];
	[controller paste:data atLocation:mouseLocation];
	[self updateFeedback:nil];
}

- (BOOL)isFlipped{
	return YES;
}

- (BOOL)isOpaque {
	return NO;
}

- (BOOL) acceptsFirstResponder{
    return YES;
}

- (void)dealloc{
	[song release];
	song = nil;
	[super dealloc];
}

@end
