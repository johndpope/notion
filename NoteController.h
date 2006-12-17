//
//  NoteController.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class NoteBase;
@class Measure;
@class ScoreView;

@interface NoteController : NSObject {

}

+ (float) widthOf:(NoteBase *)note;
+ (float) widthOf:(NoteBase *)note inMeasure:(Measure *)measure;

+ (float) xOf:(NoteBase *)note inMeasure:(Measure *)measure;

+ (BOOL)handleKeyPress:(NSEvent *)event at:(NSPoint)location on:(NoteBase *)note mode:(NSDictionary *)mode view:(ScoreView *)view;
+ (void)handleMouseClick:(NSEvent *)event at:(NSPoint)location on:(NoteBase *)note mode:(NSDictionary *)mode view:(ScoreView *)view;
+ (void)handleDrag:(NSEvent *)event to:(NSPoint)location on:(NoteBase *)note finished:(BOOL)finished mode:(NSDictionary *)mode view:(ScoreView *)view;

@end
