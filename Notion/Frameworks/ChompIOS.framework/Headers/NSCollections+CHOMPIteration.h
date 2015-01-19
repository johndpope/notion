//
//  NSCollections+CHOMPIteration.h
//  Chomp
//
//  Created by Michael Ash on 12/16/04.
//

#ifdef __APPLE__
#include "TargetConditionals.h"
#ifdef TARGET_OS_IPHONE
// iOS
#import <Foundation/Foundation.h>
#elif TARGET_IPHONE_SIMULATOR
// iOS Simulator
#import <Foundation/Foundation.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#else
// Unsupported platform
#endif
#endif


@interface NSMutableArray (CHOMPIteration)
- collect;
- do;
- each;
@end

@interface NSArray (CHOMPIteration)
- collect;
- do;
- each;
@end

@interface NSSet (CHOMPIteration)
- collect;
- do;
- each;
@end

@interface NSDictionary (CHOMPIteration)
- collect;
- do;
- each;
@end
