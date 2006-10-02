//
//  ChordDraw.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 10/1/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ChordDraw.h"
#import "Chord.h"

@implementation ChordDraw

+(void)draw:(Chord *)chord inMeasure:(Measure *)measure atIndex:(float)index isTarget:(BOOL)highlighted{
	NSEnumerator *notes = [[chord getNotes] objectEnumerator];
	id note;
	while(note = [notes nextObject]){
		[[note getViewClass] draw:note inMeasure:measure atIndex:index isTarget:highlighted];
	}
}

@end
