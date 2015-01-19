//
//  ClefController.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Clef;
@class ClefTarget;
@class ScoreView;

@interface ClefController : NSObject {

}

+ (float) widthOf:(Clef *)clef;

+ (void)handleMouseClick:(NSEvent *)event at:(NSPoint)location on:(ClefTarget *)clef mode:(NSDictionary *)mode view:(ScoreView *)view;

@end
