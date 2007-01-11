#import "NSView+Fade.h"

/**
	A category on NSView that allows fade in/out on setHidden:
 */
@implementation NSView(Fade)
/**
	Hides or unhides an NSView, making it fade in or our of existance.
 @param hidden YES to hide, NO to show
 @param fade if NO, just setHidden normally.
*/
- (IBAction)setHidden:(BOOL)hidden withFade:(BOOL)fade blocking:(BOOL)blocking{
	if(!fade) {
		// The easy way out.  Nothing to do here...
		[self setHidden:hidden];
	} else {
		if(!hidden) {
			// If we're unhiding, make sure we queue an unhide before the animation
			[self setHidden:NO];
		}
		NSMutableDictionary *animDict = [NSMutableDictionary dictionaryWithCapacity:2];
		[animDict setObject:self forKey:NSViewAnimationTargetKey];
		[animDict setObject:(hidden ? NSViewAnimationFadeOutEffect : NSViewAnimationFadeInEffect) forKey:NSViewAnimationEffectKey];
		NSViewAnimation *anim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:animDict]];
		if(blocking){
			[anim setAnimationBlockingMode:NSAnimationBlocking];
		}
		[anim setDuration:0.5];
		[anim startAnimation];
		[anim autorelease];
	}	
}

- (IBAction)setFrame:(NSRect)frame blocking:(BOOL)blocking{
	NSMutableDictionary *animDict = [NSMutableDictionary dictionaryWithCapacity:2];
	[animDict setObject:self forKey:NSViewAnimationTargetKey];
	[animDict setObject:[NSValue valueWithRect:frame] forKey:NSViewAnimationEndFrameKey];
	NSViewAnimation *anim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:animDict]];
	if(blocking){
		[anim setAnimationBlockingMode:NSAnimationBlocking];
	}
	[anim setDuration:0.5];
	[anim startAnimation];
	[anim autorelease];
}

@end