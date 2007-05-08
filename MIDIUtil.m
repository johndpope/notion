//
//  MIDIUtil.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 3/25/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import "MIDIUtil.h"
#import "Song.h"
#import "Staff.h"
#import "TimeSignature.h"
#import "TempoData.h"
#import "NoteBase.h"
#import "Note.h"
#import "Rest.h"
#import "Measure.h"

const int RESOLUTION =  480;

@implementation MIDIUtil

+ (void)writeBackwards:(char *)bytes length:(int)length to:(char *)dest{
	int i;
	for(i = 0; i < length; i++){
		dest[i] = bytes[length - 1 - i];
	}
}

+ (int)readIntFrom:(NSData *)data range:(NSRange)range{
	unsigned char *bytes = (unsigned char *)malloc(range.length);
	[data getBytes:bytes range:range];
	int rtn = 0, i = 0;
	for(i = 0; i < range.length; i++){
		rtn = rtn << 8;
		rtn += bytes[i];
	}
	free(bytes);
	return rtn;
}

+ (NSString *)readStringFrom:(NSData *)data range:(NSRange)range{
	char *bytes = (char *)malloc(range.length);
	[data getBytes:bytes range:range];
	NSString *rtn = [NSString stringWithCString:bytes length:range.length];
	free(bytes);
	return rtn;
}

+ (int)writeVariableLength:(unsigned long)data to:(char *)dest{
	if(data == 0){
		dest[0] = 0;
		return 1;
	}
	unsigned long buffer = data & 0x7F;
	
	while(data >>= 7){
		buffer <<= 8;
		buffer |= ((data & 0x7F) | 0x80);
	}
	int i;
	for(i = 0; buffer & 0x80; buffer >>= 8){
		dest[i++] = buffer & 0xFF;
	}
	dest[i++] = buffer & 0xFF;
	return i;
}

+ (int)readVariableLengthFrom:(NSData *)data into:(int *)target atOffset:(int)offset{
	char buf = 0x80;
	int size = 0, value = 0;
	while(buf & 0x80){
		[data getBytes:&buf range:NSMakeRange(offset + size, 1)];
		size++;
		value = (value << 7) + (buf & 0x7F);
	}
	*target = value;
	return size;
}

+ (NSData *)makeMTrk:(NSData *)data{
	char header[8] = {'M', 'T', 'r', 'k', 0x00, 0x00, 0x00, 0x00};
	unsigned length = [data length];
	[self writeBackwards:&length length:4 to:(header + 4)];
	NSMutableData *MTrk = [NSMutableData dataWithBytes:header length:8];
	[MTrk appendData:data];
	return MTrk;
}

static char lastStatus = 0x00;

+ (NSData *)dataForEvent:(void *)event ofType:(MusicEventType)type atTimeDelta:(MusicTimeStamp)timeDelta{
	char bytes[100];
	int timestampLength = [self writeVariableLength:(long)(timeDelta * ((float)RESOLUTION)) to:bytes];
	int size = timestampLength;
	MIDIChannelMessage *channelMsg;
	MIDINoteMessage *noteMsg;
	ExtendedTempoEvent *tempoMsg;
	MIDIMetaEvent *metaMsg;
	MIDIRawData *rawData;
	char meta, metaType, length;
	int lengthLength;
	switch(type){
		case kMusicEventType_ExtendedNote:
			//		kMusicEventType_ExtendedNote			ExtendedNoteOnEvent*
			// Apple says "non-MIDI"
			break;
		case kMusicEventType_ExtendedControl:
			//		kMusicEventType_ExtendedControl			ExtendedControlEvent*
			// Apple says "non-MIDI"
			break;
		case kMusicEventType_ExtendedTempo:
			tempoMsg = (ExtendedTempoEvent *)event;
			unsigned long tempo = (unsigned long)((float)60000000 / (tempoMsg->bpm));
			meta = 0xFF;
			metaType = 0x51;
			length = 0x03;
			[self writeBackwards:&meta length:1 to:(bytes + timestampLength)];
			[self writeBackwards:&metaType length:1 to:(bytes + timestampLength + 1)];
			[self writeBackwards:&length length:1 to:(bytes + timestampLength + 2)];
			[self writeBackwards:&tempo length:3 to:(bytes + timestampLength + 3)];
			size += 6;
			lastStatus = 0x00;
			break;
		case kMusicEventType_User:
			//		kMusicEventType_User					<user-defined-data>*
			// non-MIDI?
			break;
		case kMusicEventType_Meta:
			metaMsg = (MIDIMetaEvent *)event;
			meta = 0xFF;
			[self writeBackwards:&meta length:1 to:(bytes + timestampLength)];
			[self writeBackwards:&(metaMsg->metaEventType) length:1 to:(bytes + timestampLength + 1)];
			lengthLength = [self writeVariableLength:&(metaMsg->dataLength) to:(bytes + timestampLength + 2)];
			[self writeBackwards:&(metaMsg->data) length:(metaMsg->dataLength) to:(bytes + timestampLength + 2 + lengthLength)];
			size += 2 + lengthLength + metaMsg->dataLength;
			lastStatus = 0x00;
			break;
		case kMusicEventType_MIDINoteMessage:
			noteMsg = (MIDINoteMessage *)event;
			char status = 0x90 | noteMsg->channel;
			if(status == lastStatus){
				size -= 1;
				timestampLength -= 1;
			} else {
				[self writeBackwards:&status length:1 to:(bytes + timestampLength)];
			}
			[self writeBackwards:&(noteMsg->note) length:1 to:(bytes + timestampLength + 1)];
			[self writeBackwards:&(noteMsg->velocity) length:1 to:(bytes + timestampLength + 2)];
			size += 3;
			lastStatus = status;
			break;
		case kMusicEventType_MIDIChannelMessage:
			channelMsg = (MIDIChannelMessage *)event;
			if(status == lastStatus){
				size -= 1;
				timestampLength -= 1;
			} else {
				[self writeBackwards:&(channelMsg->status) length:1 to:(bytes + timestampLength)];
			}
			[self writeBackwards:&(channelMsg->data1) length:1 to:(bytes + timestampLength + 1)];
			[self writeBackwards:&(channelMsg->data2) length:1 to:(bytes + timestampLength + 2)];
			size += 3;
			lastStatus = status;
			break;
		case kMusicEventType_MIDIRawData:
			rawData = (MIDIRawData *)event;
			status = 0xF0;
			if(status == lastStatus){
				size -= 1;
				timestampLength -= 1;
			} else {
				[self writeBackwards:&status length:1 to:(bytes + timestampLength)];
			}
			lengthLength = [self writeVariableLength:&(rawData->length) to:(bytes + timestampLength + 1)];
			[self writeBackwards:rawData->data length:rawData->length to:(bytes + timestampLength + 1 + lengthLength)];
			size += 2 + lengthLength + rawData->length;
			break;
		case kMusicEventType_Parameter:
			//		kMusicEventType_Parameter				ParameterEvent*
			// non-MIDI
			break;
		case kMusicEventType_AUPreset:
			//		kMusicEventType_AUPreset				AUPresetEvent*
			// non-MIDI
			break;
	}
	NSData *data = [NSData dataWithBytes:bytes length:size];
	return data;
}

+ (NSData *)dataForNoteEndEventAtDelta:(MusicTimeStamp)timeDelta channel:(int)channel note:(int)note releaseVelocity:(int)velocity{
	char bytes[100];
	int timestampLength = [self writeVariableLength:(long)(timeDelta * ((float)RESOLUTION)) to:bytes];
	int size = timestampLength;
	char status = 0x80 | channel;
	if(status == lastStatus){
		size -= 1;
		timestampLength -= 1;
	} else {
		[self writeBackwards:&status length:1 to:(bytes + timestampLength)];
	}
		[self writeBackwards:&note length:1 to:(bytes + timestampLength + 1)];
	[self writeBackwards:&velocity length:1 to:(bytes + timestampLength + 2)];
	size += 3;
	lastStatus = status;
	NSData *data = [NSData dataWithBytes:bytes length:size];
	return data;
}

+ (NSData *)contentsOfTrack:(MusicTrack)track{
	NSMutableData *contents = [NSMutableData data];
	MusicEventIterator iter;
	NewMusicEventIterator(track, &iter);
	bool hasCurrent;
	MusicEventIteratorHasCurrentEvent(iter, &hasCurrent);
	MusicTimeStamp lastTimeStamp = 0;
	NSMutableArray *queuedEvents = [NSMutableArray array];
	while(hasCurrent){
		MusicTimeStamp timeStamp;
		MusicEventType eventType;
		void *data;
		int size;
		MusicEventIteratorGetEventInfo(iter, &timeStamp, &eventType, &data, &size);
		if([queuedEvents count] == 0 || [[[queuedEvents objectAtIndex:0] objectAtIndex:0] floatValue] > timeStamp){
			[contents appendData:[self dataForEvent:data ofType:eventType atTimeDelta:(timeStamp - lastTimeStamp)]];
			
			//for a note start event, queue up the end event
			if(eventType == kMusicEventType_MIDINoteMessage){
				MIDINoteMessage *msg = (MIDINoteMessage *)data;
				MusicTimeStamp endTimeStamp = (timeStamp + msg->duration);
				int i;
				for(i = 0; i < [queuedEvents count]; i++){
					if([[[queuedEvents objectAtIndex:i] objectAtIndex:0] floatValue] >= endTimeStamp){
						break;
					}
				}
				[queuedEvents insertObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:endTimeStamp],
					[NSNumber numberWithInt:msg->channel],
					[NSNumber numberWithInt:msg->note],
					[NSNumber numberWithInt:msg->releaseVelocity], nil]
								   atIndex:i];
			}
			MusicEventIteratorNextEvent(iter);
			MusicEventIteratorHasCurrentEvent(iter, &hasCurrent);
			lastTimeStamp = timeStamp;
		} else {
			NSArray *queuedEvent = [queuedEvents objectAtIndex:0];
			MusicTimeStamp timeStamp = [[queuedEvent objectAtIndex:0] floatValue];
			[contents appendData:[self dataForNoteEndEventAtDelta:(timeStamp - lastTimeStamp) 
														  channel:[[queuedEvent objectAtIndex:1] intValue]
															 note:[[queuedEvent objectAtIndex:2] intValue]
												  releaseVelocity:[[queuedEvent objectAtIndex:3] intValue]]];
			lastTimeStamp = timeStamp;
			[queuedEvents removeObjectAtIndex:0];
		}
	}

	MIDIMetaEvent *endTrack = malloc(sizeof(MIDIMetaEvent));
	endTrack->metaEventType = 0x2F;
	endTrack->dataLength = 0;
	[contents appendData:[self dataForEvent:endTrack ofType:kMusicEventType_Meta atTimeDelta:0]];
	free(endTrack);
	
	DisposeMusicEventIterator(iter);
	return contents;
}

+ (NSData *)tempoTrackContentsForSequence:(MusicSequence)seq{
	MusicTrack track;
	MusicSequenceGetTempoTrack(seq, &track);
	return [self contentsOfTrack:track];
}

+ (NSData *)contentsOfTrack:(int)index inSequence:(MusicSequence)seq{
	MusicTrack track;
	MusicSequenceGetIndTrack(seq, index, &track);
	return [self contentsOfTrack:track];
}

+ (NSData *)contentsForSequence:(MusicSequence)seq{
	NSMutableData *contents = [NSMutableData dataWithData:[self makeMTrk:[self tempoTrackContentsForSequence:seq]]];
	int tracks;
	MusicSequenceGetTrackCount(seq, &tracks);
	int i;
	for(i = 0; i < tracks; i++){
		[contents appendData:[self makeMTrk:[self contentsOfTrack:i inSequence:seq]]];
	}
	return contents;
}

+ (NSData *)writeSequenceToData:(MusicSequence)seq{
	char header[14] = {
		'M', 'T', 'h', 'd', 0x00, 0x00, 0x00, 0x06,
		0x00, 0x01, 0x00, 0x00, 0x00, 0x00
	};
	int tracks;
	MusicSequenceGetTrackCount(seq, &tracks);
	tracks += 1; //tempo track
	[self writeBackwards:&tracks length:2 to:(header + 10)];
	[self writeBackwards:&RESOLUTION length:2 to:(header + 12)];
	NSMutableData *data = [NSMutableData dataWithBytes:header length:14];
	NSData *contents = [self contentsForSequence:(MusicSequence)seq];
	[data appendData:contents];
	return data;
}

+ (int)readTrackFrom:(NSData *)data into:(Song *)song atOffset:(int)offset withResolution:(int)resolution{
	int trackSize = [self readIntFrom:data range:NSMakeRange(offset + 4, 4)];
	offset += 8;
	NSMutableDictionary *staffs = [NSMutableDictionary dictionary];
	Staff *extraStaff = nil;
	NSMutableDictionary *openNotes = [NSMutableDictionary dictionary];
	NSMutableDictionary *lastEventTimes = [NSMutableDictionary dictionary];
	int type, channel;
	while(offset < [data length]){
		int deltaTime;
		offset += [self readVariableLengthFrom:data into:&deltaTime atOffset:offset];
		float deltaBeats = (float)deltaTime / (float)resolution;
		int eventTypeAndChannel = [self readIntFrom:data range:NSMakeRange(offset, 1)];
		offset++;
		if(eventTypeAndChannel == 0xFF){
			//meta event
			int metaType = [self readIntFrom:data range:NSMakeRange(offset, 1)];
			offset++;
			int eventLength;
			offset += [self readVariableLengthFrom:data into:&eventLength atOffset:offset];
			//TODO: process delta time
			NSString *name;
			int mpqn, num, denomPower, denom, sharpsOrFlats, minor;
			float bpm;
			Staff *staff;
			if([staffs count] == 0){
				if(extraStaff == nil){
					extraStaff = [song addStaff];
				}
				staff = extraStaff;
			} else {
				staff = [[staffs allValues] objectAtIndex:0];
			}
			switch(metaType){
				case 0x03: //track name
					name = [self readStringFrom:data range:NSMakeRange(offset, eventLength)];
					[staff setName:name];
					break;
				case 0x51: //tempo change
					mpqn = [self readIntFrom:data range:NSMakeRange(offset, eventLength)];
					bpm = ((float)60000000 / mpqn);
					//TODO - get the right one based on the current time
					[[[song tempoData] lastObject] setTempo:bpm];
					break;
				case 0x58: //time signature
					//TODO: end the current measure (by changing its time signature)
					//this will be weird - what does it mean to change time signatures in the middle of a measure?
					//we will need to change the current measure's time signature to make it end where it is,
					//set the next measure's time signature so it ends where it should end, then set the specified
					//time signature in the following measure.
					num = [self readIntFrom:data range:NSMakeRange(offset, 1)];
					denomPower = [self readIntFrom:data range:NSMakeRange(offset + 1, 1)];
					denom = pow(2, denomPower);
					[song setTimeSignature:[TimeSignature timeSignatureWithTop:num bottom:denom]
								   atIndex:([[staff getMeasures] count] - 1)];
					break;
				case 0x59: //key signature
					//TODO: end the current measure (by changing its time signature)
					sharpsOrFlats = [self readIntFrom:data range:NSMakeRange(offset, 1)];
					minor = [self readIntFrom:data range:NSMakeRange(offset + 1, 1)];
					if(sharpsOrFlats >= 0){
						[[[staff getMeasures] lastObject] setKeySignature:[KeySignature getSignatureWithSharps:sharpsOrFlats minor:(minor > 0)]];
					} else {
						[[[staff getMeasures] lastObject] setKeySignature:[KeySignature getSignatureWithFlats:-sharpsOrFlats minor:(minor > 0)]];
					}
					break;
			}
			offset += eventLength;
		} else {
			//MIDI event
			int param1;
			if(eventTypeAndChannel & 0x80){
				type = eventTypeAndChannel & 0xF0;
				channel = eventTypeAndChannel & 0x0F;
				param1 = [self readIntFrom:data range:NSMakeRange(offset, 1)];
				offset++;
			} else {
				param1 = eventTypeAndChannel;
			}
			NSNumber *ch = [NSNumber numberWithInt:channel];
			int param2 = [self readIntFrom:data range:NSMakeRange(offset, 1)];
			offset++;
			Staff *staff;
			if([staffs count] == 0 && extraStaff != nil) {
				staff = extraStaff;
				[staffs setObject:staff forKey:ch];
			} else {
				staff = [staffs objectForKey:ch];
				if(staff == nil){
					staff = [song addStaff];
					[staffs setObject:staff forKey:ch];
				}
			}
			NSMutableArray *openNoteArray = [openNotes objectForKey:ch];
			if(openNoteArray == nil){
				openNoteArray = [NSMutableArray array];
				[openNotes setObject:openNoteArray forKey:ch];
			}
			Note *newNote;
			Measure *measure;
			KeySignature *keySig;
			int pitch;
			NSEnumerator *openNotesEnum;
			id openNote;
			NSNumber *lastEventTime = [lastEventTimes objectForKey:ch];
			float lastEvent;
			if(lastEventTime == nil){
				[lastEventTimes setObject:[NSNumber numberWithFloat:0] forKey:ch];
				lastEvent = 0;
			} else {
				lastEvent = [lastEventTime floatValue];
			}
			measure = [staff getLastMeasure];
			if(deltaBeats > 0){
				//TODO increase duration of open notes; add rests if none exist
				if([openNoteArray count] == 0){
					//add rests
					float restsToCreate = deltaBeats * 3 / 4;
					while(restsToCreate > 0){
						Rest *rest = [[[Rest alloc] initWithDuration:0 dotted:NO onStaff:staff] autorelease];
						if(![rest tryToFill:restsToCreate]){
							break;
						}
						restsToCreate -= [rest getEffectiveDuration];
						[measure addNote:rest atIndex:([[measure getNotes] count] - 0.5) tieToPrev:NO];
					}
				} else {
					//increase duration of open notes
					openNotesEnum = [openNoteArray objectEnumerator];
					while(openNote = [openNotesEnum nextObject]){
						[openNote tryToFill:([openNote getEffectiveDuration] + deltaBeats * 3 / 4)];
					}
				}
			}
			keySig = [measure getEffectiveKeySignature];
			switch(type) {
				case 0x80: //note off
					openNotesEnum = [openNoteArray objectEnumerator];
					while(openNote = [openNotesEnum nextObject]){
						if([openNote getEffectivePitchWithKeySignature:keySig priorAccidentals:nil] == param1){
							[openNoteArray removeObject:openNote];
						}
					}
					break;
				case 0x90: //note on
					//TODO: check for open notes, form chords as appropriate
					pitch = [keySig positionForPitch:(param1 % 12) preferAccidental:0];
					newNote = [[[Note alloc] initWithPitch:pitch octave:(param1 / 12) duration:0 dotted:NO
												accidental:[keySig accidentalForPitch:(param1 % 12) atPosition:pitch] onStaff:staff] autorelease];
					[measure addNote:newNote atIndex:([[measure getNotes] count] - 0.5) tieToPrev:NO];
					[openNoteArray addObject:newNote];
					break;
			}
			[lastEventTimes setObject:[NSNumber numberWithFloat:(lastEvent + deltaBeats)] forKey:ch];
		}
	}
	NSEnumerator *staffsEnum = [[song staffs] objectEnumerator];
	id staff;
	while(staff = [staffsEnum nextObject]) {
		NSArray *measures = [staff getMeasures];
		if([measures count] > 1 || ([measures count] == 1 && [[[measures objectAtIndex:0] getNotes] count] > 0)){
			[[[staff getMeasures] objectAtIndex:0] refreshNotes:nil];
		} else {
			[song removeStaff:staff];
		}
	}
	return trackSize + 8;
}

+ (void)readSong:(Song *)song fromMIDI:(NSData *)data{
	int format = [self readIntFrom:data range:NSMakeRange(8, 2)];
	if(format > 1){
		NSException *e = [NSException exceptionWithName:@"MIDIException" reason:@"MIDI file was an unsupported format type, must be 0 or 1." userInfo:nil];
		@throw e;
	}
	int numTracks = [self readIntFrom:data range:NSMakeRange(10, 2)];
	int resolution;
	int rawRes = [self readIntFrom:data range:NSMakeRange(12, 2)];
	if(!(rawRes & 0x8000)){
		resolution = rawRes;
	} else {
		NSException *e = [NSException exceptionWithName:@"MIDIException" reason:@"MIDI file specifies resolution in frames per second.  Import of this type of file has not yet been implemented." userInfo:nil];
		@throw e;
	}
	int i, offset = 14;
	for(i = 0; i < numTracks; i++){
		offset += [self readTrackFrom:data into:song atOffset:offset withResolution:resolution];
	}
}

@end
