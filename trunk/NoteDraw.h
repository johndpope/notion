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

+(void)draw:(NoteBase *)note inMeasure:(Measure *)measure atIndex:(float)index isTarget:(BOOL)highlighted;

@end
