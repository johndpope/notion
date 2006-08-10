//
//  MusicDocument.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/3/06.
//  Copyright __MyCompanyName__ 2006 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "MEWindowController.h"
@class Song;

@interface MusicDocument : NSDocument
{
	MEWindowController *windowController;
	Song *song;
}

- (Song *)getSong;
- (void)setSong:(Song *)_song;

@end
