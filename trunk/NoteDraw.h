//
//  NoteDraw.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/26/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class NoteBase;
@class Measure;

@interface NoteDraw : NSObject {

}

+(void)resetAccidentals;

+(BOOL)isStemUpwards:(NoteBase *)note inMeasure:(Measure *)measure;

+(void)draw:(NoteBase *)note inMeasure:(Measure *)measure atIndex:(float)index target:(id)target selection:(id)selection;
+(void)draw:(NoteBase *)note inMeasure:(Measure *)measure atIndex:(float)index isTarget:(BOOL)highlighted
   isOffset:(BOOL)offset isInChordWithOffset:(BOOL)hasOffset stemUpwards:(BOOL)stemUpwards drawStem:(BOOL)stem drawTriplet:(BOOL)triplet;

+(float)stemXForNote:(NoteBase *)note inMeasure:(Measure *)measure upwards:(BOOL)up;
+(float)stemStartYForNote:(NoteBase *)note inMeasure:(Measure *)measure;
+(float)topOf:(NoteBase *)note inMeasure:(Measure *)measure;
+(float) bottomOf:(NoteBase *)note inMeasure:(Measure *)measure;
+(NSRect)bodyRectFor:(NoteBase *)note atIndex:(float)index inMeasure:(Measure *)measure;

@end
