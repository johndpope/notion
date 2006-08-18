//
//  RestDraw.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/26/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NoteDraw.h"
@class Note;
@class Clef;

@interface RestDraw : NoteDraw {

}

+(void)draw:(Note *)note atX:(NSNumber *)x highlighted:(BOOL)highlighted
   withClef:(Clef *)clef onMeasure:(NSRect)measure;

@end
