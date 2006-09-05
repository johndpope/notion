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
	[[[song undoManager] prepareWithInvocationTarget:self] setTempo:tempo];
	tempo = _tempo;
}

- (BOOL) empty{
	return tempo < 0;
}

- (id) initWithTempo:(float)_tempo withSong:(Song *)_song{
	if((self = [super init])){
		song = _song;
		tempo = _tempo;
	}
	return self;
}

- (id) initEmptyWithSong:(Song *)_song{
	if((self = [super init])){
		song = _song;
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
	[[song undoManager] setActionName:@"changing tempo"];
	tempo = [sender floatValue];
	if(tempo == 0) tempo = -1;
	[self refreshTempo];
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:song forKey:@"song"];
	[coder encodeFloat:tempo forKey:@"tempo"];
}

- (id)initWithCoder:(NSCoder *)coder{
	if(self = [super init]){
		song = [coder decodeObjectForKey:@"song"];
		[self setTempo:[coder decodeFloatForKey:@"tempo"]];
	}
	return self;
}

@end
