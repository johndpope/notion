//
//  self.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "ScoreController.h"
#import "StaffController.h"
#import "MeasureController.h"
#import "NoteController.h"
#import "Song.h"
#import "Measure.h"
#import "TimeSignature.h"
#import "Repeat.h"

@implementation ScoreController

+ (float)staffSpacing{
	return 5.0;
}

+ (float)xInset{
	return 5.0;
}

+ (float)yInset{
	return 5.0;
}

+ (NSArray *)notesAtBeats:(float)beats inSong:(Song *)song{
	NSMutableArray *notes = [NSMutableArray array];
	Staff *firstStaff = [[song staffs] objectAtIndex:0];
	float currBeats = 0;
	int measureIndex = 0;
	int repeatCount = 1;
	while(measureIndex < [song getNumMeasures]){
		float measureLength = 4.0 * [[song getEffectiveTimeSignatureAt:measureIndex] getMeasureDuration] / 3;
		if(currBeats + measureLength > beats){
			break;
		}
		currBeats += measureLength;
		Repeat *repeat = [song repeatEndingAt:measureIndex];
		if(repeat != nil){
			if(repeatCount < [repeat numRepeats]){
				repeatCount++;
				measureIndex = [repeat startMeasure];
			} else {
				repeatCount = 1;
				measureIndex++;
			}				
		} else {
			measureIndex++;			
		}
	}
	beats -= currBeats;
	NSArray *measures = [[[song staffs] collect] getMeasureAtIndex:measureIndex];
	NSEnumerator *measuresEnum = [measures objectEnumerator];
	id measure;
	while(measure = [measuresEnum nextObject]){
		if(![measure isKindOfClass:[NSNull class]]){
			NoteBase *note = [measure getClosestNoteBefore:(beats * 3 / 4)];
			if(note != nil){
				[notes addObject:note];
			}
		}
	}
	return notes;
}

+ (Staff *)staffAt:(NSPoint)location inSong:(Song *)song{
	float y = location.y;
	NSEnumerator *staffs = [[song staffs] objectEnumerator];
	id staff;
	float currY = [self yInset];
	while(staff = [staffs nextObject]){
		int staffHeight = [StaffController heightOf:staff];
		if(currY + staffHeight >= y) return staff;
		currY += staffHeight + [self staffSpacing];
	}
	return [[song staffs] lastObject];
}

+ (id) targetAtLocation:(NSPoint)location inSong:(Song *)song mode:(NSDictionary *)mode withEvent:(NSEvent *)event{
	Staff *staff = [self staffAt:location inSong:song];
	location.y -= [StaffController boundsOf:staff].origin.y;
	return [StaffController targetAtLocation:location inStaff:staff mode:mode withEvent:(NSEvent *)event];	
}

@end
