//
//  MeasureController.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Measure;
@class NoteBase;
@class ScoreView;

@interface MeasureController : NSObject {
	
}

+ (float)noteAreaStart:(Measure *)measure;
+ (float)minNoteSpacing;

+ (float)widthOf:(Measure *)measure;
+ (float)xOf:(Measure *)measure;
+ (NSRect)boundsOf:(Measure *)measure;
+ (NSRect)innerBoundsOf:(Measure *)measure;

+ (int)octaveAt:(NSPoint)location inMeasure:(Measure *)measure;
+ (int)pitchAt:(NSPoint)location inMeasure:(Measure *)measure;

+ (float)indexAt:(NSPoint)location inMeasure:(Measure *)measure;
+ (float)xOfIndex:(float)index inMeasure:(Measure *)measure;

+ (BOOL) isOverClef:(NSPoint)location inMeasure:(Measure *)measure;

+ (BOOL) isOverTimeSig:(NSPoint)location inMeasure:(Measure *)measure;

+ (BOOL) isOverKeySig:(NSPoint)location inMeasure:(Measure *)measure;

+ (BOOL)isOverNote:(NoteBase *)note at:(NSPoint)location inMeasure:(Measure *)measure;

+ (NSPoint) keySigPanelLocationFor:(Measure *)measure;
+ (NSPoint) timeSigPanelLocationFor:(Measure *)measure;

+ (id)targetAtLocation:(NSPoint)location inMeasure:(Measure *)measure mode:(int)mode;
+ (void)handleMouseClick:(NSEvent *)event at:(NSPoint)location on:(Measure *)measure mode:(NSDictionary *)mode view:(ScoreView *)view;
+ (BOOL)handleKeyPress:(NSEvent *)event at:(NSPoint)location on:(Measure *)measure mode:(NSDictionary *)mode view:(ScoreView *)view;

@end
