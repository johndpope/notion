//
//  Drum+Lilypond.m
//  Se–or Staff
//
//  Created by Konstantine Prevas on 5/28/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import "Drum+Lilypond.h"


@implementation Drum(Lilypond)

- (NSString *)lilypondString{
	int note = octave * 12 + pitch;
	if(note < 37){
		return @"bd";
	}
	if(note == 37){
		return @"ss";
	}
	if(note < 41){
		return @"sn";
	}
	if(note == 41){
		return @"tomfl";
	}
	if(note == 42){
		return @"hhc";
	}
	if(note == 43){
		return @"tomfh";
	}
	if(note == 44){
		return @"hhp";
	}
	if(note == 45){
		return @"toml";
	}
	if(note == 46){
		return @"hho";
	}
	if(note == 47){
		return @"tomml";
	}
	if(note == 48){
		return @"tommh";
	}
	if(note == 49 || note == 57){
		return @"cymc";
	}
	if(note == 50){
		return @"tomh";
	}
	if(note == 51 || note == 59 || note == 53){
		return @"cymr";
	}
	if(note == 52 || note == 55){
		return @"cyms";
	}
	return @"hc";
}


@end
