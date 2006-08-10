//
//  MeasureDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MeasureDraw.h"
#import "Measure.h"
#import "Clef.h"

@implementation MeasureDraw

static MeasureDraw *instance = nil;

-(void)setMeasure:(Measure *)_measure{
	measure = _measure;
}

-(void)setBounds:(NSRect)_bounds{
	bounds = _bounds;
}

-(void)setBase:(float)_baseY{
	baseY = _baseY;
}

-(void)setMouseOverClef:(BOOL)_mouseOverClef{
	mouseOverClef = _mouseOverClef;
}

-(void)setMouseOverTimeSig:(BOOL)_mouseOverTimeSig{
	mouseOverTimeSig = _mouseOverTimeSig;
}

-(void)setMouseOverKeySig:(BOOL)_mouseOverKeySig{
	mouseOverKeySig = _mouseOverKeySig;
}

-(void)setLineHeight:(float)_lineHeight{
	lineHeight = _lineHeight;
}

-(void)setClefWidth:(float)_clefWidth{
	clefWidth = _clefWidth;
}

-(void)setTimeSigWidth:(float)_timeSigWidth{
	timeSigWidth = _timeSigWidth;
}

+(void)draw:(Measure *)_measure withBounds:(NSRect)_bounds base:(NSNumber *)_baseY
		lineHeight:(NSNumber *)_lineHeight clefWidth:(NSNumber *)_clefWidth
		timeSigWidth:(NSNumber *)_timeSigWidth
		mouseOverClef:(BOOL)_mouseOverClef
		mouseOverTimeSig:(BOOL)_mouseOverTimeSig
		mouseOverKeySig:(BOOL)_mouseOverKeySig{
	if(instance == nil){
		instance = [[MeasureDraw alloc] init];
	}
	[instance setMeasure:_measure];
	[instance setBounds:_bounds];
	[instance setBase:[_baseY floatValue]];
	[instance setMouseOverClef:_mouseOverClef];
	[instance setMouseOverTimeSig:_mouseOverTimeSig];
	[instance setMouseOverKeySig:_mouseOverKeySig];
	[instance setLineHeight:[_lineHeight floatValue]];
	[instance setClefWidth:[_clefWidth floatValue]];
	[instance setTimeSigWidth:[_timeSigWidth floatValue]];
	[instance draw];	
}

-(void)draw{
	[NSBezierPath strokeRect:bounds];
	int i;
	for(i=1; i<=3; i++){
		NSPoint point1, point2;
		point1.x = bounds.origin.x;
		point2.x = bounds.origin.x + bounds.size.width;
		point1.y = point2.y = bounds.origin.y + i * bounds.size.height / 4;
		[NSBezierPath strokeLineFromPoint:point1 toPoint:point2];
	}
	
	[self drawClef:[measure getClef]];
	
	TimeSignature *timeSig = nil;
	if([measure hasTimeSignature]){
		timeSig = [measure getTimeSignature];
	}
	[self drawTimeSig:timeSig];
	
	[self drawKeySig:[measure getKeySignature]];
}

-(void)drawClef:(Clef *)clef{
	if(clef != nil){
		[[clef getViewClass] draw:clef atX:[NSNumber numberWithFloat:bounds.origin.x] base:[NSNumber numberWithFloat:baseY] 
					  highlighted:mouseOverClef];
	} else if(mouseOverClef){
		NSImage *clefIns;
		if([measure getEffectiveClef] == [Clef trebleClef]){
			clefIns = [NSImage imageNamed:@"clefins_bass.png"];
		} else{
			clefIns = [NSImage imageNamed:@"clefins_treble.png"];
		}
		[clefIns compositeToPoint:NSMakePoint(bounds.origin.x, bounds.origin.y) operation:NSCompositeSourceOver];
	}	
}

-(void)drawTimeSig:(TimeSignature *)sig{
	if(sig != nil){
		NSPoint accLoc;
		accLoc.x = bounds.origin.x + clefWidth;
		accLoc.y = baseY - lineHeight * 18;
		NSMutableDictionary *atts = [NSMutableDictionary dictionary];
		[atts setObject:[NSFont fontWithName:@"Musicator" size:160] forKey:NSFontAttributeName];
		if(mouseOverTimeSig){
			[atts setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
		} else{
			[atts setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
		}
		[[NSString stringWithFormat:@"%d", [sig getBottom]] drawAtPoint:accLoc withAttributes:atts];
		accLoc.y -= lineHeight * 4;
		[[NSString stringWithFormat:@"%d", [sig getTop]] drawAtPoint:accLoc withAttributes:atts];			
		[[NSColor blackColor] set];
	} else if(mouseOverTimeSig){
		NSImage *sigIns = [NSImage imageNamed:@"timesig_insert.png"];
		[sigIns compositeToPoint:NSMakePoint(bounds.origin.x + clefWidth, bounds.origin.y) operation:NSCompositeSourceOver];			
	}	
}

-(void)drawKeySig:(KeySignature *)sig{
	if(sig != nil && ([sig getNumSharps] > 0 || [sig getNumFlats] > 0)){
		NSPoint accLoc;
		accLoc.x = bounds.origin.x + clefWidth + timeSigWidth;
		NSEnumerator *sharps = [[sig getSharps] objectEnumerator];
		NSNumber *sharp;
		NSImage *sharpImg;
		if(mouseOverKeySig){
			sharpImg = [NSImage imageNamed:@"sharp over.png"];
		} else{
			sharpImg = [NSImage imageNamed:@"sharp.png"];
		}
		while(sharp = [sharps nextObject]){
			int sharpLoc = [sharp intValue];
			accLoc.y = baseY - lineHeight * sharpLoc + 7.0;
			[sharpImg compositeToPoint:accLoc operation:NSCompositeSourceOver];
			accLoc.x += 10.0;
		}
		NSEnumerator *flats = [[sig getFlats] objectEnumerator];
		NSNumber *flat;
		NSImage *flatImg;
		if(mouseOverKeySig){
			flatImg = [NSImage imageNamed:@"flat over.png"];
		} else{
			flatImg = [NSImage imageNamed:@"flat.png"];
		}
		while(flat = [flats nextObject]){
			int flatLoc = [flat intValue];
			accLoc.y = baseY - lineHeight * flatLoc + 3.0;
			[flatImg compositeToPoint:accLoc operation:NSCompositeSourceOver];
			accLoc.x += 10.0;
		}
	} else if(mouseOverKeySig && ![measure isShowingKeySigPanel]){
		NSImage *sigIns = [NSImage imageNamed:@"keysig_insert.png"];
		[sigIns compositeToPoint:NSMakePoint(bounds.origin.x + clefWidth + timeSigWidth, bounds.origin.y) operation:NSCompositeSourceOver];			
	}	
}

@end
