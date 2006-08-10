//
//  TempoData.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/2/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class StaffHorizontalRulerComponent;

@interface TempoData : NSObject <NSCoding> {
	float tempo;
	IBOutlet StaffHorizontalRulerComponent *tempoPanel;
	IBOutlet NSTextField *tempoText;
}

- (float) tempo;
- (void) setTempo:(float)_tempo;

- (BOOL) empty;

- (id) initWithTempo:(float)_tempo;
- (id) initEmpty;

- (NSView *)tempoPanel;
- (void) removePanel;

- (IBAction)tempoChanged:(id)sender;

@end
