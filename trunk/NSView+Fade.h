
#import <Cocoa/Cocoa.h>


@interface NSView(Fade)

- (IBAction)setHidden:(BOOL)hidden withFade:(BOOL)fade blocking:(BOOL)blocking;
- (IBAction)setFrame:(NSRect)frame blocking:(BOOL)blocking;

@end
