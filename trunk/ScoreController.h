//
//  ScoreController.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Song;
@class Staff;

@interface ScoreController : NSObject {

}

+ (float)staffSpacing;
+ (float)xInset;
+ (float)yInset;

+ (Staff *)staffAt:(NSPoint)location inSong:(Song *)song;

+ (id)targetAtLocation:(NSPoint)location inSong:(Song *)song mode:(NSDictionary *)mode withEvent:(NSEvent *)event;

@end
