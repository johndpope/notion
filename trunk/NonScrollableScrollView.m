//
//  NonScrollableScrollView.m
//  Music Editor
//
//  Created by Konstantine Prevas on 6/6/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "NonScrollableScrollView.h"


@implementation NonScrollableScrollView

- (void)scrollWheel:(NSEvent *)event{
	[owner scrollWheel:event];
}

@end
