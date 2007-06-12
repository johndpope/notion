//
//  Drum+MusicXML.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 6/10/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import "Drum+MusicXML.h"

@implementation Drum(MusicXML)

- (NSString *)musicXMLString{
	NSMutableString *string = [NSMutableString string];
	
	int note = octave * 12 + pitch;
	if(note < 37){
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>F</display-step>\n"];
		[string appendString:@"<display-octave>4</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
	} else if(note == 37){
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>C</display-step>\n"];
		[string appendString:@"<display-octave>5</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
		[string appendString:@"<notehead>x</notehead>\n"];
	} else if(note < 41){
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>C</display-step>\n"];
		[string appendString:@"<display-octave>5</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
	} else if(note == 41){
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>E</display-step>\n"];
		[string appendString:@"<display-octave>4</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
	} else if(note == 42){
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>E</display-step>\n"];
		[string appendString:@"<display-octave>5</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
		[string appendString:@"<notehead>cross</notehead>\n"];
	} else if(note == 43){
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>G</display-step>\n"];
		[string appendString:@"<display-octave>4</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
	} else if(note == 44){
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>D</display-step>\n"];
		[string appendString:@"<display-octave>4</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
		[string appendString:@"<notehead>x</notehead>\n"];
	} else if(note == 45){
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>A</display-step>\n"];
		[string appendString:@"<display-octave>4</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
	} else if(note == 46){
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>E</display-step>\n"];
		[string appendString:@"<display-octave>5</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
		[string appendString:@"<notehead>circle-x</notehead>\n"];
	} else if(note == 47){
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>B</display-step>\n"];
		[string appendString:@"<display-octave>4</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
	} else if(note == 48){
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>D</display-step>\n"];
		[string appendString:@"<display-octave>5</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
	} else if(note == 49 || note == 57){
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>G</display-step>\n"];
		[string appendString:@"<display-octave>5</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
		[string appendString:@"<notehead>circle-x</notehead>\n"];
	} else if(note == 50){
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>F</display-step>\n"];
		[string appendString:@"<display-octave>5</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
	} else if(note == 51 || note == 59 || note == 53){
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>G</display-step>\n"];
		[string appendString:@"<display-octave>5</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
		[string appendString:@"<notehead>x</notehead>\n"];
	} else if(note == 52 || note == 55){
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>G</display-step>\n"];
		[string appendString:@"<display-octave>5</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
		[string appendString:@"<notehead>slash</notehead>\n"];
	} else {
		[string appendString:@"<unpitched>\n"];
		[string appendString:@"<display-step>C</display-step>\n"];
		[string appendString:@"<display-octave>5</display-octave>\n"];
		[string appendString:@"</unpitched>\n"];
		[string appendString:@"<notehead>inverted triangle</notehead>\n"];
	}
	
	[string appendFormat:@"<instrument id=\"%@\"/>\n", shortName];
	
	return string;
}
	