//
//  NSView+ScaleUtilities.h
//

#import <Cocoa/Cocoa.h>


@interface NSView(ScaleUtilities)

- (NSSize) scale;
- (void) setScale:(NSSize) newScale;
- (void) resetScaling;

@end
