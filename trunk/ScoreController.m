//
//  self.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "ScoreController.h"
#import "StaffController.h"
#import "Song.h"

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
