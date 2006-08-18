//
//  TempoData.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/2/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "TempoData.h"
#import "StaffHorizontalRulerComponent.h"

@implementation TempoData

- (float) tempo{
	return tempo;
}

- (void) setTempo:(float)_tempo{
	tempo = _tempo;
}

- (BOOL) empty{
	return tempo < 0;
}

- (id) initWithTempo:(float)_tempo{
	if((self = [super init])){
		tempo = _tempo;
	}
	return self;
}

- (id) initEmpty{
	if((self = [super init])){
		tempo = -1;
	}
	return self;
}

- (NSView *)tempoPanel{
	return tempoPanel;
}

- (void) refreshTempo{
	if(tempo > 0){
		[tempoText setFloatValue:tempo];
		[tempoPanel setShouldFade:NO];
		[tempoPanel setHidden:NO];
	} else{
		[tempoText setStringValue:@""];
		[tempoPanel setShouldFade:YES];
	}
}

- (void) removePanel{
	[tempoPanel removeFromSuperview];
}

- (IBAction)tempoChanged:(id)sender{
	tempo = [sender floatValue];
	if(tempo == 0) tempo = -1;
	[self refreshTempo];
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeFloat:tempo forKey:@"tempo"];
}

- (id)initWithCoder:(NSCoder *)coder{
	if(self = [super init]){
		[self setTempo:[coder decodeFloatForKey:@"tempo"]];
	}
	return self;
}

@end
