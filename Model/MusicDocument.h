//
//  MusicDocument.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/3/06.
//  Copyright Konstantine Prevas 2006 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "MEWindowController.h"
@class Song;

@interface MusicDocument : NSDocument{
	MEWindowController *windowController;
	Song *song;
}

- (Song *)getSong;
- (void)setSong:(Song *)_song;

- (IBAction)goToHomepage:(id)sender;
- (IBAction)goToBugReport:(id)sender;
- (IBAction)goToDonate:(id)sender;

@end
