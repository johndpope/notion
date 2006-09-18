//
//  TimeSignatureController.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TimeSignature;
@class TimeSigTarget;
@class ScoreView;

@interface TimeSignatureController : NSObject {

}

+ (float) widthOf:(TimeSignature *)timeSig;

+ (void)handleMouseClick:(NSEvent *)event at:(NSPoint)location on:(TimeSigTarget *)sig mode:(NSDictionary *)mode view:(ScoreView *)view;

@end
