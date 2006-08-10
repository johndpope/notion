//
//  RestDraw.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/26/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Note;
@class Clef;

@interface RestDraw : NSObject {

}

+(void)draw:(Note *)note atX:(float)x highlighted:(BOOL)highlighted
   withClef:(Clef *)clef onMeasure:(NSRect)measure;

@end
