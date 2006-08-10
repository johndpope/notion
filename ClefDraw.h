//
//  ClefDraw.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Clef;

@interface ClefDraw : NSObject {

}

+(void)draw:(Clef *)clef atX:(NSNumber *)x base:(NSNumber *)baseY highlighted:(BOOL)highlighted;

@end
