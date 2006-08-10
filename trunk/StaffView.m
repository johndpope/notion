//
//  StaffView.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/3/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "StaffView.h"
#import "MEWindowController.h"
#import "Song.h"
#import "Staff.h"
#import "Measure.h"
#import "Note.h"
#import "NoteDraw.h"
#import "Clef.h"
#import "TimeSignature.h"

@implementation StaffView

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

- (float)xInset{
	return 5.0;
}

- (float)yInset{
	return 5.0;
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
		int width = [self calcStaffWidth:staff];
		bounds.size.height += [self calcStaffHeight:staff] + [self staffSpacing];
		bounds.size.width = (bounds.size.width < width) ? width : bounds.size.width;
	}
	bounds.size.width += 5 * [self xInset];
	bounds.size.height += 2 * [self yInset];
	NSEnumerator *subviews = [[self subviews] objectEnumerator];
	id subview;
	while(subview = [subviews nextObject]){
		bounds = NSUnionRect(bounds, [subview frame]);
	}
	return bounds;
}

- (float)calcStaffWidth:(Staff *)staff{
	float width=0;
	NSEnumerator *measures = [[staff getMeasures] objectEnumerator];
	id measure;
	while(measure = [measures nextObject]){
		width += [self calcMeasureWidth:measure];
	}
	return width;
}

- (float)calcStaffHeight:(Staff *)staff{
	return 150.0;
}

- (float)calcStaffLineHeight:(Staff *)staff{
	return [self calcStaffHeight:staff] / 24.0;
}

- (NSRect)calcStaffBounds:(Staff *)staff{
	NSRect staffBounds;
	staffBounds.origin.x = [self xInset];
	staffBounds.origin.y = [self yInset];
	int i;
	int staffIndex = [[song staffs] indexOfObject:staff];
	for(i=0; i<staffIndex; i++){
		staffBounds.origin.y += [self calcStaffHeight:[[song staffs] objectAtIndex:i]] + [self staffSpacing];
	}
	staffBounds.size.height = [self calcStaffHeight:staff];
	staffBounds.size.width = 0;
	NSEnumerator *measures = [[staff getMeasures] objectEnumerator];
	id measure;
	while(measure = [measures nextObject]){
		staffBounds.size.width += [self calcMeasureWidth:measure];
	}
	return staffBounds;
}

- (float)calcStaffBase:(Staff *)staff fromTop:(float)y{
	return y + 50 + 8.0 * [self calcStaffLineHeight:staff];
}

- (float)calcStaffTop:(Staff *)staff{
	NSEnumerator *staffs = [[song staffs] objectEnumerator];
	id currStaff;
	float currY = [self yInset];
	while(currStaff = [staffs nextObject]){
		int staffHeight = [self calcStaffHeight:staff];
		if(currStaff == staff) return currY;
		currY += staffHeight + [self staffSpacing];
	}
	return currY;
}

- (float)calcSingleMeasureWidth:(Measure *)measure{
	if(measure == nil) return 0;
	float width = [self minNoteSpacing];
	NSEnumerator *notes = [[measure getNotes] objectEnumerator];
	id note;
	while(note = [notes nextObject]){
		width += [self calcNoteWidth:note] + [self minNoteSpacing];
	}
	if(width < 150.0) width = 150.0;
	width += [self calcMeasureNoteAreaStart:measure];
	return width;
}

- (float)calcMeasureWidth:(Measure *)measure{
	float max = 0;
	int index = [[[measure getStaff] getMeasures] indexOfObject:measure];
	NSEnumerator *staffs = [[song staffs] objectEnumerator];
	id staff;
	while(staff = [staffs nextObject]){
		if([[staff getMeasures] count] > index){
			float width = [self calcSingleMeasureWidth:[[staff getMeasures] objectAtIndex:index]];
			if(width > max) max = width;
		}
	}
	return max;
}

- (float)keySignatureWidth:(KeySignature *)sig{
	int numSymbols = [sig getNumSharps] + [sig getNumFlats];
	if(numSymbols == 0) return [self keySignatureAreaWidth];
	return numSymbols * 10.0;
}

- (float)calcClefWidth:(Measure *)measure{
	if([measure getClef] != nil){
		return [self clefWidth];
	} else{
		return [self clefAreaWidth];
	}
}

- (float)calcKeySignatureWidth:(Measure *)measure{
	if([measure getKeySignature] != nil){
		return [self keySignatureWidth:[measure getKeySignature]];
	} else{
		return [self keySignatureAreaWidth];
	}
}

- (float)calcTimeSignatureWidth:(Measure *)measure{
	if([measure getTimeSignature] != nil){
		return [self timeSignatureWidth];
	} else{
		return [self timeSignatureAreaWidth];
	}
}

- (float)calcMeasureNoteAreaStart:(Measure *)measure{
	return [self calcClefWidth:measure] + [self calcKeySignatureWidth:measure] + [self calcTimeSignatureWidth:measure];
}

- (float)calcNoteWidth:(Note *)note{
	return (72.0 / [note getDuration]) * ([note getDotted] ? 1.5 : 1);
}

- (float) calcNoteDisplayWidth: (Note *)note inMeasure:(Measure *)measure{
	float width = [self calcNoteWidth:note];
	float noteStart = [measure getNoteStartDuration:note];
	float noteEnd = [measure getNoteEndDuration:note];
	int measureIndex = [[[measure getStaff] getMeasures] indexOfObject:measure];
	NSEnumerator *staffs = [[song staffs] objectEnumerator];
	int max = 0;
	id staff;
	while(staff = [staffs nextObject]){
		if([[staff getMeasures] count] > measureIndex){
			Measure *measure = [[staff getMeasures] objectAtIndex:measureIndex];
			int numNotes = [measure getNumberOfNotesStartingAt:noteStart endingAt:noteEnd];
			if(numNotes > max) max = numNotes;
		}
	}
	return width + max * [self minNoteSpacing];
}

- (float)staffSpacing{
	return 5.0;
}

- (float)minNoteSpacing{
	return 15.0;
}

- (float)clefWidth{
	return 35.0;
}

- (float)timeSignatureWidth{
	return 20.0;
}

- (float)clefAreaWidth{
	return 10.0;
}

- (float)keySignatureAreaWidth{
	return 10.0;
}

- (float)timeSignatureAreaWidth{
	return 10.0;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
	
    }
    return self;
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
				err = ATSFontFindFromContainer(
											   container,
											   kATSOptionFlagsDefault,
											   100,
											   fontRefs,
											   &fontCount );
				
				if( err != noErr || fontCount < 1 )
					return;
				
				NSString *fontName;
				err = ATSFontGetPostScriptName(
											   fontRefs[0],
											   kATSOptionFlagsDefault,
											   &fontName);
			}
		}
	}
}

- (void) awakeFromNib{
	[[self window] setAcceptsMouseMovedEvents:true];
	[self loadLocalFonts];
	feedbackNote = [[Note alloc] init];
	[feedbackNote setDuration:4];
	[feedbackNote setDotted:NO];
	[feedbackNote setAccidental:NO_ACC];
	clefFeedback = [NSObject alloc];
	keySigFeedback = [NSObject alloc];
	timeSigFeedback = [NSObject alloc];
	mouseOverColor = [[NSColor colorWithDeviceRed:0.8 green:0 blue:0 alpha:1] retain];
}

- (void)drawRect:(NSRect)rect {
	[NoteDraw resetAccidentals];
	NSEnumerator *staffs = [[song staffs] objectEnumerator];
	id staff;
	NSAffineTransform *xform = [NSAffineTransform transform];
	[xform translateXBy:[self xInset] yBy:[self yInset]];
	[xform concat];
	float y = 0;
	while(staff = [staffs nextObject]){
		[self drawStaff:staff y:y];
		y += [self calcStaffHeight:staff] + [self staffSpacing];
	}
	[xform invert];
	[xform concat];
}

- (void)drawStaff:(Staff *)staff y:(float)y{
	NSEnumerator *measures = [[staff getMeasures] objectEnumerator];
	id measure;
	float x = 0;
	Clef *clef;
	while(measure = [measures nextObject]){
		if([measure getClef] != nil) clef = [measure getClef];
		float width = [self calcMeasureWidth:measure];
		[self drawMeasure:measure x:x top:y base:[self calcStaffBase:staff fromTop:y] height:[self calcStaffHeight:staff] lineHeight:[self calcStaffLineHeight:staff] withClef:clef];
		x += width;
	}
}

- (void)drawMeasure:(Measure *)measure x:(float)x top:(float)y base:(float)baseY height:(float)height lineHeight:(float)line withClef:(Clef *)clef{
	int i;
	NSRect bounds;
	bounds.origin.x = x;
	bounds.origin.y = y + 50;
	bounds.size.height = height - 100;
	bounds.size.width = [self calcMeasureWidth:measure];
	if([self needsToDrawRect:bounds]){
		[NSBezierPath strokeRect:bounds];
		for(i=1; i<=3; i++){
			NSPoint point1, point2;
			point1.x = bounds.origin.x;
			point2.x = bounds.origin.x + bounds.size.width;
			point1.y = point2.y = bounds.origin.y + i * bounds.size.height / 4;
			[NSBezierPath strokeLineFromPoint:point1 toPoint:point2];
		}
		
		if([measure getClef] != nil){
			NSImage *clef;
			NSPoint clefLoc;
			clefLoc.x = x;
			if([measure getClef] == [Clef trebleClef]){
				if(measure == feedbackMeasure && clefFeedback == mouseOver){
					clef = [NSImage imageNamed:@"treble over.png"];
				} else{
					clef = [NSImage imageNamed:@"treble.png"];
				}
				clefLoc.y = baseY + 20;
			} else if([measure getClef] == [Clef bassClef]){
				if(measure == feedbackMeasure && clefFeedback == mouseOver){
					clef = [NSImage imageNamed:@"bass over.png"];
				} else{
					clef = [NSImage imageNamed:@"bass.png"];
				}
				clefLoc.y = baseY - 7;
			}
			[clef compositeToPoint:clefLoc operation:NSCompositeSourceOver];
		} else if(mouseOver == clefFeedback && measure == feedbackMeasure){
			NSImage *clefIns;
			if([measure getEffectiveClef] == [Clef trebleClef]){
				clefIns = [NSImage imageNamed:@"clefins_bass.png"];
			} else{
				clefIns = [NSImage imageNamed:@"clefins_treble.png"];
			}
			[clefIns compositeToPoint:NSMakePoint(x, bounds.origin.y) operation:NSCompositeSourceOver];
		}
		
		if([measure hasTimeSignature]){
			NSPoint accLoc;
			accLoc.x = x + [self calcClefWidth:measure];
			TimeSignature *sig = [measure getTimeSignature];
			accLoc.y = baseY - line * 18;
			NSMutableDictionary *atts = [NSMutableDictionary dictionary];
			[atts setObject:[NSFont fontWithName:@"Musicator" size:160] forKey:NSFontAttributeName];
			if(measure == feedbackMeasure && mouseOver == timeSigFeedback){
				[atts setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
			} else{
				[atts setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
			}
			[[NSString stringWithFormat:@"%d", [sig getBottom]] drawAtPoint:accLoc withAttributes:atts];
			accLoc.y -= line * 4;
			[[NSString stringWithFormat:@"%d", [sig getTop]] drawAtPoint:accLoc withAttributes:atts];			
			[[NSColor blackColor] set];
		} else if(mouseOver == timeSigFeedback && measure == feedbackMeasure /*&&
					![measure isShowingTimeSigPanel]*/){
			NSImage *sigIns = [NSImage imageNamed:@"timesig_insert.png"];
			[sigIns compositeToPoint:NSMakePoint(x + [self calcClefWidth:measure], bounds.origin.y) operation:NSCompositeSourceOver];			
		}
		
		if([measure getKeySignature] != nil && ([[measure getKeySignature] getNumSharps] > 0 || [[measure getKeySignature] getNumFlats] > 0)){
			NSPoint accLoc;
			accLoc.x = x + [self calcClefWidth:measure] + [self calcTimeSignatureWidth:measure];
			NSEnumerator *sharps = [[[measure getKeySignature] getSharps] objectEnumerator];
			NSNumber *sharp;
			NSImage *sharpImg;
			if(mouseOver == keySigFeedback && measure == feedbackMeasure){
				sharpImg = [NSImage imageNamed:@"sharp over.png"];
			} else{
				sharpImg = [NSImage imageNamed:@"sharp.png"];
			}
			while(sharp = [sharps nextObject]){
				int sharpLoc = [sharp intValue];
				accLoc.y = baseY - line * sharpLoc + 7.0;
				[sharpImg compositeToPoint:accLoc operation:NSCompositeSourceOver];
				accLoc.x += 10.0;
			}
			NSEnumerator *flats = [[[measure getKeySignature] getFlats] objectEnumerator];
			NSNumber *flat;
			NSImage *flatImg;
			if(mouseOver == keySigFeedback && measure == feedbackMeasure){
				flatImg = [NSImage imageNamed:@"flat over.png"];
			} else{
				flatImg = [NSImage imageNamed:@"flat.png"];
			}
			while(flat = [flats nextObject]){
				int flatLoc = [flat intValue];
				accLoc.y = baseY - line * flatLoc + 3.0;
				[flatImg compositeToPoint:accLoc operation:NSCompositeSourceOver];
				accLoc.x += 10.0;
			}
		} else if(mouseOver == keySigFeedback && measure == feedbackMeasure &&
					![measure isShowingKeySigPanel]){
			NSImage *sigIns = [NSImage imageNamed:@"keysig_insert.png"];
			[sigIns compositeToPoint:NSMakePoint(x + [self calcClefWidth:measure] + [self calcTimeSignatureWidth:measure], bounds.origin.y) operation:NSCompositeSourceOver];			
		}
		
		NSEnumerator *notes = [[measure getNotes] objectEnumerator];
		id note;
		x += [self calcMeasureNoteAreaStart:measure] + [self minNoteSpacing];
		while(note = [notes nextObject]){
			[self drawNote:note x:x y:baseY measure:bounds lineHeight:line withClef:clef];
			x += [self calcNoteDisplayWidth:note inMeasure:measure] + [self minNoteSpacing];
		}
		if(measure == feedbackMeasure && [feedbackNote getDuration] > 0){
			[[NSColor blueColor] set];
			x = [self getXForIndex:feedbackX forStaff:feedbackStaff forMeasure:measure];
			[self drawNote:feedbackNote x:x y:baseY measure:bounds lineHeight:line withClef:clef];
			[[NSColor blackColor] set];
		}
	}
}

- (void)drawNote:(Note *)note x:(float)x y:(float)y measure:(NSRect)measure lineHeight:(float)line withClef:(Clef *)clef{
	[[note getViewClass] draw:note atX:x highlighted:(note == mouseOver)
					 withClef:clef onMeasure:measure];
}

- (int)getOctaveAtY:(float)y forStaff:(Staff *)staff staffTop:(float)staffTop forMeasure:(Measure *)measure{
	int position = ([self calcStaffBase:staff fromTop:staffTop] - y + ([self calcStaffLineHeight:staff] / 2)) / [self calcStaffLineHeight:staff];
	return [[measure getEffectiveClef] getOctaveForPosition:position];
}

- (int)getPitchAtY:(float)y forStaff:(Staff *)staff staffTop:(float)staffTop forMeasure:(Measure *)measure{
	int position = ([self calcStaffBase:staff fromTop:staffTop] - y + ([self calcStaffLineHeight:staff] / 2)) / [self calcStaffLineHeight:staff];
	return [[measure getEffectiveClef] getPitchForPosition:position];
}

- (Staff *)getStaffAtY:(float)y{
	NSEnumerator *staffs = [[song staffs] objectEnumerator];
	id staff;
	float currY = [self yInset];
	while(staff = [staffs nextObject]){
		int staffHeight = [self calcStaffHeight:staff];
		if(currY + staffHeight >= y) return staff;
		currY += staffHeight + [self staffSpacing];
	}
	return [[song staffs] lastObject];
}

- (Measure *)getMeasureAtX:(float)x forStaff:(Staff *)staff{
	NSEnumerator *measures = [[staff getMeasures] objectEnumerator];
	id measure;
	float currX = [self xInset];
	while(measure = [measures nextObject]){
		float measureWidth = [self calcMeasureWidth:measure];
		if(currX + measureWidth > x) return measure;
		currX += measureWidth;
	}
	return [[staff getMeasures] lastObject];
}

- (float)getIndexAtX:(float)x forStaff:(Staff *)staff forMeasure:(Measure *)measure{
	NSEnumerator *measures = [[staff getMeasures] objectEnumerator];
	x -= [self xInset];
	id currMeasure;
	while((currMeasure = [measures nextObject]) && currMeasure != measure){
		x -= [self calcMeasureWidth:currMeasure];
	}
	NSEnumerator *notes = [[measure getNotes] objectEnumerator];
	id note;
	float index = -0.5;
	x -= [self minNoteSpacing] + [self calcMeasureNoteAreaStart:measure];
	while((note = [notes nextObject]) && x > 0){
		index += 0.5;
		x -= 12;
		if(x <= 0) break;
		x -= [self calcNoteDisplayWidth:note inMeasure:measure] + [self minNoteSpacing] - 12;
		index += 0.5;
	}
	return index;
}

- (float)getXForMeasure:(Measure *)measure forStaff:(Staff *)staff{
	float x = [self xInset];
	NSEnumerator *measures = [[staff getMeasures] objectEnumerator];
	id currMeasure;
	while((currMeasure = [measures nextObject]) && currMeasure != measure){
		x += [self calcMeasureWidth:currMeasure];
	}
	return x;
}

- (float)getXForIndex:(float)index forStaff:(Staff *)staff forMeasure:(Measure *)measure{
	float measureX = [self getXForMeasure:measure forStaff:staff];
	float x = measureX + [self minNoteSpacing] + [self calcMeasureNoteAreaStart:measure];
	if([[measure getNotes] count] > 0){
		NSEnumerator *notes = [[measure getNotes] objectEnumerator];
		id note = [notes nextObject];
		while(index >= 1 && note){
			x += [self calcNoteDisplayWidth:note inMeasure:measure] + [self minNoteSpacing];
			note = [notes nextObject];
			index -= 1;
		}
		if(note == nil) note = [[measure getNotes] lastObject];
		if(index < 0){
			x -= [self minNoteSpacing];
		} else if(index > 0){
			if(note == [[measure getNotes] lastObject]){
				x += [self calcNoteDisplayWidth:note inMeasure:measure] + [self minNoteSpacing];
			} else{
				x += [self calcNoteDisplayWidth:note inMeasure:measure] / 2;
			}
		}
	}
	if(x + [self minNoteSpacing] > measureX + [self calcMeasureWidth:measure]){
		x = measureX + [self calcMeasureWidth:measure] - [self minNoteSpacing];
	}
	return x;
}

- (BOOL) isOverClef:(NSPoint)location inMeasure:(Measure *)measure inStaff:(Staff *)staff{
	return location.x - [self getXForMeasure:measure forStaff:staff] <= [self calcClefWidth:measure];
}

- (BOOL) isOverTimeSig:(NSPoint)location inMeasure:(Measure *)measure inStaff:(Staff *)staff{
	return location.x - [self getXForMeasure:measure forStaff:staff] <= [self calcClefWidth:measure] + [self calcTimeSignatureWidth:measure];
}

- (BOOL) isOverKeySig:(NSPoint)location inMeasure:(Measure *)measure inStaff:(Staff *)staff{
	return location.x - [self getXForMeasure:measure forStaff:staff] <= [self calcClefWidth:measure] + [self calcTimeSignatureWidth:measure] + [self calcKeySignatureWidth:measure];
}

- (void)mouseDown:(NSEvent *)event{
	NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
	Staff *staff = [self getStaffAtY:location.y];
	Measure *measure = [self getMeasureAtX:location.x forStaff:staff];
	float staffTop = [self calcStaffTop:staff];
	int octave = [self getOctaveAtY:location.y forStaff:staff staffTop:staffTop forMeasure:measure];
	int pitch = [self getPitchAtY:location.y forStaff:staff staffTop:staffTop forMeasure:measure];
	[controller clickedAtLocation:location onStaff:staff onMeasure:measure
		atPitch:pitch atOctave:octave atXIndex:feedbackX onClef:(mouseOver==clefFeedback)
		onKeySig:(mouseOver==keySigFeedback) onTimeSig:(mouseOver==timeSigFeedback)
		button:[event buttonNumber]];
	[self setFrameSize:[self calculateBounds].size];
	[self updateFeedback:event];
}

- (void)mouseMoved:(NSEvent *)event{
	[self setFrameSize:[self calculateBounds].size];
	if([self mouse:[self convertPoint:[event locationInWindow] fromView:nil] inRect:[self frame]]){
		[self updateFeedback:event];
	}
}

- (void)keyDown:(NSEvent *)event{
	if(![controller keyPressed:event onStaff:feedbackStaff onMeasure:feedbackMeasure atXIndex:feedbackX]){
		[super keyDown:event];
	}
	[self setFrameSize:[self calculateBounds].size];
	[self setNeedsDisplay:YES];
}

- (void)updateFeedback:(NSEvent *)event{
	NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
	feedbackStaff = [self getStaffAtY:location.y];
	feedbackMeasure = [self getMeasureAtX:location.x forStaff:feedbackStaff];
	feedbackX = [self getIndexAtX:location.x forStaff:feedbackStaff forMeasure:feedbackMeasure];
	
	if([controller getMode] == MODE_NOTE){
		float staffTop = [self calcStaffTop:feedbackStaff];
		int octave = [self getOctaveAtY:location.y forStaff:feedbackStaff staffTop:staffTop forMeasure:feedbackMeasure];
		int pitch = [self getPitchAtY:location.y forStaff:feedbackStaff staffTop:staffTop forMeasure:feedbackMeasure];
		[feedbackNote setPitch:pitch];
		[feedbackNote setOctave:octave];
	}
	
	else if([controller getMode] == MODE_POINT){
		if([self isOverClef:location inMeasure:feedbackMeasure inStaff:feedbackStaff]){
			mouseOver = clefFeedback;
		} else if([self isOverTimeSig:location inMeasure:feedbackMeasure inStaff:feedbackStaff]){
			mouseOver = timeSigFeedback;
		} else if([self isOverKeySig:location inMeasure:feedbackMeasure inStaff:feedbackStaff]){
			mouseOver = keySigFeedback;
		} else{
			mouseOver = nil;
			if(![feedbackMeasure isEmpty]){
				mouseOver = [[feedbackMeasure getNotes] objectAtIndex:(floor(feedbackX) >= 0 ? floor(feedbackX) : 0)];
			}
		}
	}
	
	[self setNeedsDisplay:YES];
}

- (void)setFeedbackNoteDuration:(int)_duration{
	[feedbackNote setDuration:_duration];
	mouseOver = nil;
	[self setNeedsDisplay:YES];
}

- (void)setFeedbackNoteDotted:(BOOL)_dotted{
	[feedbackNote setDotted:_dotted];
}

- (void)setFeedbackNoteAccidental:(int)_accidental{
	[feedbackNote setAccidental:_accidental];
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
	[feedbackNote release];
	[clefFeedback release];
	[keySigFeedback release];
	[timeSigFeedback release];
	[mouseOverColor release];
	song = nil;
	feedbackNote = nil;
	clefFeedback = nil;
	keySigFeedback = nil;
	timeSigFeedback = nil;
	mouseOverColor = nil;
	[super dealloc];
}

@end
