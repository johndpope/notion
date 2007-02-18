//
//  ChordDraw.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 10/1/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Chord;
@class Measure;
#import "NoteDraw.h"

@interface ChordDraw : NoteDraw {

}

+ (BOOL)isStemUpwards:(Chord *)chord inMeasure:(Measure *)measure;

+ (float) topOf:(Chord *)chord inMeasure:(Measure *)measure;

+(void)draw:(Chord *)chord inMeasure:(Measure *)measure atIndex:(float)index target:(id)target selection:(id)selection;

@end
