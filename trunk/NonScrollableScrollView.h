//
//  NonScrollableScrollView.h
//  Music Editor
//
//  Created by Konstantine Prevas on 6/6/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NonScrollableScrollView : NSScrollView {
	IBOutlet NSView *owner;
}

@end
