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
	NSEnumerator *measuresEnum = [[firstStaff getMeasures] objectEnumerator];
	id measure;
	int measureIndex = 0;
	while(measure = [measuresEnum nextObject]){
		float measureLength = 4.0 * [measure getTotalDuration] / 3;
		if(currBeats + measureLength > beats){
			break;
		}
		currBeats += measureLength;
		measureIndex++;
	}
	beats -= currBeats;
	NSArray *measures = [[[song staffs] collect] getMeasureAtIndex:measureIndex];
	measuresEnum = [measures objectEnumerator];
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
