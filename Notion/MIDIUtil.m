#import "MIDIUtil.h"
//#import "Song.h"
//#import "Staff.h"
//#import "TimeSignature.h"
//#import "TempoData.h"
//#import "NoteBase.h"
//#import "Note.h"
//#import "Rest.h"
//#import "Measure.h"
//#import <AudioToolbox/MusicPlayer.h>
//#import "Chord.h"
#import "JPNoteEvent.h"


const int RESOLUTION =  480; // this will dynamically get adjusted below to match midi file

typedef enum {
    Intro      = 0,
    Original      = 1,
    Variation     = 2,
    Variation2     = 3,
    FillToOriginal             = 4,
    FillToVariation = 5,
    FillToVariation2 = 6,
    Ending = 7
} CurrentPart;

typedef enum {
    Major      = 0,
    Minor      = 1,
    Seventh     = 2,
} ChordType;

@interface InstrumentAddress :NSObject;
-(int)addressForChordType:(ChordType)type;
@property(nonatomic) int16_t major;
@property(nonatomic) int16_t minor;
@property(nonatomic) int16_t seventh;
@property(nonatomic,strong) NSMutableArray *notes;
-(id)initWithMajor:(int)major minor:(int)minor seventh:(int)seventh;
-(BOOL)isAvailableChordType:(ChordType)type;
@end

@implementation InstrumentAddress

-(int)addressForChordType:(ChordType)type{
    if (type == Major) {
        return self.major;
    }
    if (type == Minor) {
        return self.minor;
    }
    if (type == Seventh) {
        return self.seventh;
    }
    return -1;
}
-(id)initWithMajor:(int)major minor:(int)minor seventh:(int)seventh{
    self = [super init];
    self.minor =minor;
    self.major =major;
    self.seventh =seventh;
    return self;
}
-(BOOL)isAvailableChordType:(ChordType)type{
    if (type == Major) {
        if (self.major > 0) {
            return YES;
        }
    }
    if (type == Minor) {
        if (self.minor > 0) {
            return YES;
        }
    }
    if (type == Seventh ) {
        if (self.seventh > 0) {
            return YES;
        }
    }
    return NO;
}
@end


@interface StylePart : NSObject
@property(nonatomic,strong) InstrumentAddress *address;
@property(nonatomic) CurrentPart part;

@end

@implementation StylePart



@end

@implementation MIDIUtil


/*
 
 /// Reads the style's signature (0x0 - 0x1)
 private void GetStyleSignature() {
 string SignatureText = Encoding.ASCII.GetString(this.FileContents, 0x0, 2);
 switch (SignatureText) {
 case "G8": this._signature = StyleSignature.G8; break;
 case "EV": this._signature = StyleSignature.EV; break;
 
 /// Reads the style's name (0x2 - 0x11)
 private void GetStyleName() {
 this._name = Encoding.ASCII.GetString(this.FileContents, 0x2, 16);
 
 /// Reads the style's tempo (0x14 - 0x15)
 private void GetTempo() {
 int DivBy = System.Net.IPAddress.HostToNetworkOrder(BitConverter.ToInt16(this.FileContents, 0x14));
 this._tempo = 500000 / DivBy;
 
 /// Reads the metronome mark of the style.
 /// Numerator: 0x18
 /// Denominator: 0x19 (2^value)
 int BeatsInMeasure = (int)this.FileContents[0x18];
 int BeatLength = (int)Math.Pow(2, this.FileContents[0x19]);
 
 this._measure = new Measure(BeatsInMeasure, BeatLength);
 */

+ (void)readStylesFromFile {
    NSString *style = [[NSBundle mainBundle] pathForResource:@"12-8Bal_SFF" ofType:@"STL"];
    NSData *data = [NSData dataWithContentsOfFile:style];
    // NSLog(@"data:%@", data);
    
    NSString *signature = [self readStringFrom:data range:NSMakeRange(0x0, 0x1)];
    NSLog(@"signature:%@", signature);
    
    NSString *styleName = [self readStringFrom:data range:NSMakeRange(0x2, 0x16)];
    NSLog(@"styleName:%@", styleName);
    int16_t t2 = [self readInt16From:data offset:0x14 length:1];
    short t1 = [data rw_int16AtOffset:0x14];
    //int DivBy = System.Net.IPAddress.HostToNetworkOrder(BitConverter.ToInt16(this.FileContents, 0x14));
    // this._tempo = 500000 / DivBy;
    NSLog(@" tempo:%d", 500000 / t1);
    
    int numerator = [self readIntFrom:data offset:0x18 length:1];
    NSLog(@"numerator:%d", numerator);
    int denominator = [self readIntFrom:data offset:0x19 length:1];
    NSLog(@"Denominator:%d", denominator * denominator);

   // return;
    /// Reads the addresses from the file (0x3A - 0x639)
    /// </summary>
    NSMutableDictionary *basicAddresses = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *advancedAddresses = [[NSMutableDictionary alloc]init];
    int CurrentInstrument = 0;
    for (int16_t StartOffset = 0x3A; StartOffset <= 0x639; StartOffset += 192, CurrentInstrument++) {
        [self readData:data instrumentAddress:StartOffset instrument:CurrentInstrument targetDict:basicAddresses];
        [self readData:data instrumentAddress:(StartOffset + 96) instrument:CurrentInstrument targetDict:advancedAddresses];
    }
    NSLog(@"basicAddresses:%@",basicAddresses);
    NSLog(@"advancedAddresses:%@",advancedAddresses);
    

    
}


/// <summary>
/// Reads up the addresses of a given instrument
/// </summary>
/// <param name="InstrStartOffset">The start offset of the data</param>
/// <param name="Instr">Which instrument to read</param>
/// <param name="TargetDict">The target dictionary to store the address data</param>
/// <param name="InstrStartOffset">The start offset of the data</param>
/// <param name="Instr">Which instrument to read</param>
//    /// <param name="TargetDict">The target dictionary to store the address data</param>
//    private void ReadInstrumentAddress(int InstrStartOffset, Instrument Instr, Dictionary<Instrument, Dictionary<StylePart, InstrumentAddress>> TargetDict) {
//        for (int CurrentPart = 0; CurrentPart < 8; CurrentPart++) {
//            int PartStart = CurrentPart * 12;
//
//            int Major = BitConverter.ToInt16(this.FileContents, InstrStartOffset + PartStart);
//            int Minor = BitConverter.ToInt16(this.FileContents, InstrStartOffset + PartStart + 4);
//            int Seventh = BitConverter.ToInt16(this.FileContents, InstrStartOffset + PartStart + 8);
//
//            TargetDict[Instr].Add(
//                                  (StylePart)CurrentPart,
//                                  new InstrumentAddress(Major, Minor, Seventh)
//                                  );
//        }
//    }
//

+ (void)readData:(NSData *)data instrumentAddress:(int16_t)InstrStartOffset instrument:(int16_t)instrument0 targetDict:(NSMutableDictionary *)targetDict {
    
    NSMutableArray *arr = [NSMutableArray array];
    
    for (int CurrentPart = 0; CurrentPart < 8; CurrentPart++) {
        int PartStart = CurrentPart * 12;

        //data bytes = 60434
        int offset =InstrStartOffset + PartStart;
        int16_t major = [data big_rw_int16AtOffset: offset]; // 3194 exe app - isLittleEndian = false / BIG ENDIAN style file format
        int16_t minor = [data big_rw_int16AtOffset:offset + 4 ];
        int16_t seventh = [data big_rw_int16AtOffset:offset +  8];
        
     // NSLog(@" major:%d minor:%d seventh:%d",major, minor, seventh);
        StylePart *style = [[StylePart alloc]init];
        style.address  =[[InstrumentAddress alloc]initWithMajor:major minor:minor seventh:seventh];
        style.part =CurrentPart;
         [self addMidiMessagesFromData:data instrument:style.address chordType:Major];
        [arr addObject:style];
    }
    NSString *instrument = [NSString stringWithFormat:@"%d",instrument0];
    [targetDict setValue:arr forKey:instrument];
    
}



+ (void )addMidiMessagesFromData:(NSData *)data instrument:(InstrumentAddress*)instrumentAddress chordType:(ChordType)chordType {

    if (![instrumentAddress isAvailableChordType:chordType]) {
        return;
    }
    if ( [instrumentAddress addressForChordType:chordType] >data.length){
        return;
        
    }
   int Addr  = [instrumentAddress addressForChordType:chordType];
    
    int time = 0;
    instrumentAddress.notes = [NSMutableArray array];
    
    for (int Offset = Addr; true; Offset += 6) {
        //    MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
      //   int16_t noteTime = [data big_rw_int16AtOffset: Offset];
        int noteTime = [self readIntFrom:data offset:Offset length:1];
        int dx = [self readIntFrom:data offset:Offset + 1 length:1];
        if (dx == 0x8F) {
            break;
        }
       
       NSData *d1 = [data subdataWithRange:NSMakeRange(Offset, 6)];
        Byte *bytePtr = (Byte *)[d1 bytes];

      
      //  NSLog(@"deltaTime  %hhu note : %hhu  channel: %hhu %hhu %hhu %hhu ", bytePtr[0],bytePtr[1],bytePtr[2],bytePtr[3],bytePtr[4],bytePtr[5]);
        JPNoteEvent *note = [[JPNoteEvent alloc]init];
        [note setMessageType:bytePtr[1]];
        note.timeStamp = time  +bytePtr[0];
        note.note =bytePtr[1];
        note.channel =bytePtr[2];
        note.velocity =bytePtr[3];
        note.duration =bytePtr[5]+1;
        
        
        
        /*
         /// <para>0x11 - Bass</para>
         /// <para>0x19 - Drum</para>
         /// <para>0x10 - Acc1</para>
         /// <para>0x12 - Acc2</para>
         /// <para>0x14 - Acc3</para>
         /// <para>0x16 - Acc4</para>
         /// <para>0x18 - Acc5</para>
         /// <para>0x20 - Acc6</para>
         */
        
        if (note.msgType == Note) {
            [instrumentAddress.notes addObject:note];
               time =time + noteTime;
        }else{
       
        }
    }
//    NSSortDescriptor *earliestNotes = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES];
//    [instrumentAddress.notes sortUsingDescriptors:[NSArray arrayWithObject:earliestNotes]];
    
    NSLog(@":%@",instrumentAddress.notes);

}

/*
 
 
 /// <summary>
 /// Gets the events from the given style part
 /// </summary>
 /// <param name="IsBasic">True if Basic, False if Advanced</param>
 /// <param name="Part">Part of the style</param>
 /// <param name="Instr">Track of the part</param>
 /// <param name="CType">Chord type</param>
 /// <returns>A list of the events</returns>
 public IEnumerable<MidiMessage> this[bool IsBasic, StylePart Part, Instrument Instr, ChordType CType] {
 get {
 Dictionary<Instrument, Dictionary<StylePart, InstrumentAddress>> Source =
 IsBasic ? this.BasicAddresses : this.AdvancedAddresses;
 
 InstrumentAddress addr = Source[Instr][Part];
 
 return this.GetMidiMessages(addr, CType);
 }
 }
 
 /// <summary>
 /// Addresses of the style's Basic part
 /// </summary>
 private Dictionary<Instrument, Dictionary<StylePart, InstrumentAddress>> BasicAddresses;
 
 /// <summary>
 /// Addresses of the style's Advanced part
 /// </summary>
 private Dictionary<Instrument, Dictionary<StylePart, InstrumentAddress>> AdvancedAddresses;
 
 /// <summary>
 /// Loads the given Roland style file
 /// </summary>
 /// <param name="Filename">The path to the file</param>
 public Reader_STL_2var(string Filename) {
 this.FileContents = File.ReadAllBytes(Filename);
 
 this.ReadFile();
 }
 
 /// <summary>
 /// Loads the Roland style from the given stream
 /// </summary>
 /// <param name="File">A stream that contains the file</param>
 public Reader_STL_2var(Stream File) {
 using (BinaryReader reader = new BinaryReader(File)) {
 this.FileContents = reader.ReadBytes((int)File.Length);
 }
 
 this.ReadFile();
 }
 
 /// <summary>
 /// Reads up the whole file
 /// </summary>
 private void ReadFile() {
 this.GetStyleSignature();
 this.GetStyleName();
 this.GetTempo();
 this.GetMeasure();
 
 this.BasicAddresses = new Dictionary<Instrument, Dictionary<StylePart, InstrumentAddress>>();
 this.AdvancedAddresses = new Dictionary<Instrument, Dictionary<StylePart, InstrumentAddress>>();
 for (int i = 0; i < 8; i++) {
 this.BasicAddresses.Add((Instrument)i, new Dictionary<StylePart, InstrumentAddress>());
 this.AdvancedAddresses.Add((Instrument)i, new Dictionary<StylePart, InstrumentAddress>());
 }
 
 this.ReadAddresses();
 
 /// Reads the metronome mark of the style.
 ///
 /// Numerator: 0x18
 /// Denominator: 0x19 (2^value)
 /// </summary>
 private void GetMeasure() {
 int BeatsInMeasure = (int)this.FileContents[0x18];
 int BeatLength = (int)Math.Pow(2, this.FileContents[0x19]);
 
 this._measure = new Measure(BeatsInMeasure, BeatLength);
 }
 
 /// <summary>
 /// Reads the addresses from the file (0x3A - 0x639)
 /// </summary>
 private void ReadAddresses() {
 Instrument CurrentInstrument = 0;
 for (int StartOffset = 0x3A; StartOffset <= 0x639; StartOffset += 192, CurrentInstrument++) {
 this.ReadInstrumentAddress(StartOffset, CurrentInstrument, BasicAddresses);
 this.ReadInstrumentAddress(StartOffset + 96, CurrentInstrument, AdvancedAddresses);
 }
 }
 
 /// <summary>
 /// Reads up the addresses of a given instrument
 /// </summary>
 /// <param name="InstrStartOffset">The start offset of the data</param>
 /// <param name="Instr">Which instrument to read</param>
 /// <param name="TargetDict">The target dictionary to store the address data</param>
 private void ReadInstrumentAddress(int InstrStartOffset, Instrument Instr, Dictionary<Instrument, Dictionary<StylePart, InstrumentAddress>> TargetDict) {
 for (int CurrentPart = 0; CurrentPart < 8; CurrentPart++) {
 int PartStart = CurrentPart * 12;
 
 int Major = BitConverter.ToInt16(this.FileContents, InstrStartOffset + PartStart);
 int Minor = BitConverter.ToInt16(this.FileContents, InstrStartOffset + PartStart + 4);
 int Seventh = BitConverter.ToInt16(this.FileContents, InstrStartOffset + PartStart + 8);
 
 TargetDict[Instr].Add(
 (StylePart)CurrentPart,
 new InstrumentAddress(Major, Minor, Seventh)
 );
 }
 }
 
 /// <summary>
 /// Reads the MIDI messages at the given address
 /// </summary>
 /// <param name="Address">The address to read</param>
 /// <param name="CType">The chord family to read</param>
 /// <returns>A collection that stores the MidiMessage instances</returns>
 private IEnumerable<MidiMessage> GetMidiMessages(InstrumentAddress Address, ChordType CType) {
 int Addr;
 
 if (Address.IsAvailable(CType) && Address[CType] < this.FileContents.Length) {
 Addr = Address[CType];
 }
 else
 yield break;
 
 int Time = 0;
 for (int Offset = Addr; true; Offset += 6) {
 if (this.FileContents[Offset + 1] == 0x8F)
 yield break;
 
 byte[] Data = new byte[6];
 Array.Copy(
 this.FileContents,
 Offset,
 Data,
 0,
 6
 );
 
 MidiMessage msg = MidiMessage.CreateFromData(Data, Time);
 Time += this.FileContents[Offset];
 
 yield return msg;
 }
 }
 }
 }}*/


+ (void)writeBackwards:(char *)bytes length:(int)length to:(char *)dest {
    int i;
    for (i = 0; i < length; i++) {
        dest[i] = bytes[length - 1 - i];
    }
}

+ (int)readIntFrom:(NSData *)data offset:(unsigned int)offset length:(unsigned int)length {
    NSRange range = NSMakeRange(offset, length);
    unsigned char *bytes = (unsigned char *)malloc(range.length);
    [data getBytes:bytes range:range];
    int rtn = 0, i = 0;
    for (i = 0; i < range.length; i++) {
        rtn = rtn << 8;
        rtn += bytes[i];
    }
    free(bytes);
    return rtn;
}
+ (int16_t)endian16_readInt16From:(NSData *)data offset:(unsigned int)offset length:(unsigned int)length {
   return  EndianS16_BtoN([MIDIUtil readInt16From:data offset:offset length:length] );
}
+ (int16_t)readInt16From:(NSData *)data offset:(unsigned int)offset length:(unsigned int)length {
    NSRange range = NSMakeRange(offset, length);
    unsigned char *bytes = (unsigned char *)malloc(range.length);
    [data getBytes:bytes range:range];
    int16_t rtn = 0, i = 0;
    for (i = 0; i < range.length; i++) {
        rtn = rtn << 8;
        rtn += bytes[i];
    }
    free(bytes);
    return rtn;
}

+ (NSString *)readStringFrom:(NSData *)data range:(NSRange)range {
    char *bytes = (char *)malloc(range.length);
    [data getBytes:bytes range:range];
    NSString *rtn = [NSString stringWithCString:bytes length:range.length];
    free(bytes);
    return rtn;
}

+ (int)writeVariableLength:(unsigned long)data to:(char *)dest {
    if (data == 0) {
        dest[0] = 0;
        return 1;
    }
    unsigned long buffer = data & 0x7F;
    
    while (data >>= 7) {
        buffer <<= 8;
        buffer |= ((data & 0x7F) | 0x80);
    }
    int i;
    for (i = 0; buffer &0x80; buffer >>= 8) {
        dest[i++] = buffer & 0xFF;
    }
    dest[i++] = buffer & 0xFF;
    return i;
}

+ (int)readVariableLengthFrom:(NSData *)data into:(int *)target atOffset:(int)offset {
    char buf = 0x80;
    int size = 0, value = 0;
    while (buf & 0x80) {
        [data getBytes:&buf range:NSMakeRange(offset + size, 1)];
        size++;
        value = (value << 7) + (buf & 0x7F);
    }
    *target = value;
    return size;
}

+ (NSData *)makeMTrk:(NSData *)data {
    char header[8] = { 'M', 'T', 'r', 'k', 0x00, 0x00, 0x00, 0x00 };
    unsigned length = [data length];
    [self writeBackwards:&length length:4 to:(header + 4)];
    NSMutableData *MTrk = [NSMutableData dataWithBytes:header length:8];
    [MTrk appendData:data];
    return MTrk;
}

static char lastStatus = 0x00;

+ (NSData *)dataForEvent:(void *)event ofType:(MusicEventType)type atTimeDelta:(MusicTimeStamp)timeDelta timeStamp:(MusicTimeStamp)timeStamp sequence:(MusicSequence)seq {
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
    switch (type) {
        case kMusicEventType_ExtendedNote:
            //		kMusicEventType_ExtendedNote			ExtendedNoteOnEvent*
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
            lengthLength = [self writeVariableLength:metaMsg->dataLength to:(bytes + timestampLength + 2)];
            [self writeBackwards:&(metaMsg->data) length:(metaMsg->dataLength) to:(bytes + timestampLength + 2 + lengthLength)];
            size += 2 + lengthLength + metaMsg->dataLength;
            lastStatus = 0x00;
            break;
            
        case kMusicEventType_MIDINoteMessage:
            noteMsg = (MIDINoteMessage *)event;
            [self showNoteInformationWithNote:noteMsg timestamp:timeStamp sequence:seq timeResolution:RESOLUTION];
            char status = 0x90 | noteMsg->channel;
            if (status == lastStatus) {
                size -= 1;
                timestampLength -= 1;
            }
            else {
                [self writeBackwards:&status length:1 to:(bytes + timestampLength)];
            }
            [self writeBackwards:&(noteMsg->note) length:1 to:(bytes + timestampLength + 1)];
            [self writeBackwards:&(noteMsg->velocity) length:1 to:(bytes + timestampLength + 2)];
            size += 3;
            lastStatus = status;
            break;
            
        case kMusicEventType_MIDIChannelMessage:
            channelMsg = (MIDIChannelMessage *)event;
            if (status == lastStatus) {
                size -= 1;
                timestampLength -= 1;
            }
            else {
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
            if (status == lastStatus) {
                size -= 1;
                timestampLength -= 1;
            }
            else {
                [self writeBackwards:&status length:1 to:(bytes + timestampLength)];
            }
            lengthLength = [self writeVariableLength:rawData->length to:(bytes + timestampLength + 1)];
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

+ (NSData *)dataForNoteEndEventAtDelta:(MusicTimeStamp)timeDelta channel:(int)channel note:(int)note releaseVelocity:(int)velocity {
    char bytes[100];
    int timestampLength = [self writeVariableLength:(long)(timeDelta * ((float)RESOLUTION)) to:bytes];
    int size = timestampLength;
    char status = 0x80 | channel;
    if (status == lastStatus) {
        size -= 1;
        timestampLength -= 1;
    }
    else {
        [self writeBackwards:&status length:1 to:(bytes + timestampLength)];
    }
    [self writeBackwards:&note length:1 to:(bytes + timestampLength + 1)];
    [self writeBackwards:&velocity length:1 to:(bytes + timestampLength + 2)];
    size += 3;
    lastStatus = status;
    NSData *data = [NSData dataWithBytes:bytes length:size];
    return data;
}

+ (NSData *)contentsOfTrack:(MusicTrack)track sequence:(MusicSequence)sequence {
    NSMutableData *contents = [NSMutableData data];
    MusicEventIterator iter;
    NewMusicEventIterator(track, &iter);
    bool hasCurrent;
    MusicEventIteratorHasCurrentEvent(iter, &hasCurrent);
    MusicTimeStamp lastTimeStamp = 0;
    NSMutableArray *queuedEvents = [NSMutableArray array];
    while (hasCurrent) {
        MusicTimeStamp timeStamp;
        MusicEventType eventType;
        void *data;
        int size;
        MusicEventIteratorGetEventInfo(iter, &timeStamp, &eventType, &data, &size);
        if ([queuedEvents count] == 0 || [[[queuedEvents objectAtIndex:0] objectAtIndex:0] floatValue] > timeStamp) {
            [contents appendData:[self dataForEvent:data ofType:eventType atTimeDelta:(timeStamp - lastTimeStamp) timeStamp:timeStamp sequence:sequence]];
            
            //for a note start event, queue up the end event
            if (eventType == kMusicEventType_MIDINoteMessage) {
                MIDINoteMessage *msg = (MIDINoteMessage *)data;
                MusicTimeStamp endTimeStamp = (timeStamp + msg->duration);
                int i;
                for (i = 0; i < [queuedEvents count]; i++) {
                    if ([[[queuedEvents objectAtIndex:i] objectAtIndex:0] floatValue] >= endTimeStamp) {
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
        }
        else {
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
    [contents appendData:[self dataForEvent:endTrack ofType:kMusicEventType_Meta atTimeDelta:0 timeStamp:0 sequence:sequence]];
    free(endTrack);
    
    DisposeMusicEventIterator(iter);
    return contents;
}

+ (NSData *)tempoTrackContentsForSequence:(MusicSequence)seq {
    MusicTrack track;
    MusicSequenceGetTempoTrack(seq, &track);
    return [self contentsOfTrack:track sequence:seq];
}

+ (NSData *)contentsOfTrack:(int)index inSequence:(MusicSequence)seq {
    MusicTrack track;
    MusicSequenceGetIndTrack(seq, index, &track);
    return [self contentsOfTrack:track sequence:seq];
}

+ (NSData *)contentsForSequence:(MusicSequence)seq {
    NSMutableData *contents = [NSMutableData dataWithData:[self makeMTrk:[self tempoTrackContentsForSequence:seq]]];
    int tracks;
    MusicSequenceGetTrackCount(seq, &tracks);
    int i;
    for (i = 0; i < tracks; i++) {
        [contents appendData:[self makeMTrk:[self contentsOfTrack:i inSequence:seq]]];
    }
    return contents;
}

+ (NSData *)writeSequenceToData:(MusicSequence)seq {
    char header[14] = {
        'M', 'T', 'h', 'd', 0x00, 0x00, 0x00, 0x06,
        0x00, 0x01, 0x00, 0x00, 0x00, 0x00
    };
    int tracks;
    MusicSequenceGetTrackCount(seq, &tracks);
    tracks += 1;  //tempo track
    [self writeBackwards:&tracks length:2 to:(header + 10)];
    [self writeBackwards:&RESOLUTION length:2 to:(header + 12)];
    NSMutableData *data = [NSMutableData dataWithBytes:header length:14];
    NSData *contents = [self contentsForSequence:(MusicSequence)seq];
    [data appendData:contents];
    return data;
}

+ (void)processMidiFileWithName:(NSString *)name  {
    MusicSequence seq;
    MusicPlayer player;
    
    // Initialise the music sequence
    NewMusicSequence(&seq);
    
    
    NSLog(@"processing midi file");
    NSString *midiFilePath = [[NSBundle mainBundle] pathForResource:name ofType:@"mid"];
    NSURL *midiFileURL = [NSURL fileURLWithPath:midiFilePath];
    OSStatus err = MusicSequenceFileLoad(seq, (__bridge CFURLRef)midiFileURL, 0, 0);
    NSLog(@"err:%d", err);
    
    
    NewMusicPlayer(&player);
    MusicPlayerSetSequence(player, seq);
    
    MusicTrack tempoTrack;
    MusicSequenceGetTempoTrack(seq, &tempoTrack);
    
    MusicTrack trebleTrack;
    MusicTrack bassTrack;
    MusicSequenceNewTrack(seq, &trebleTrack);
    MusicSequenceNewTrack(seq, &bassTrack);
    
    //http://ericjknapp.com/blog/2014/03/30/midi-files-and-tracks/
    MusicSequenceGetIndTrack(seq, 0, &trebleTrack);
    MusicSequenceGetIndTrack(seq, 1, &bassTrack);
    
    MusicEventIterator iterator;
    NewMusicEventIterator(trebleTrack, &iterator);
    
    
    // Pulses Per Quarter note
    // http://ericjknapp.com/blog/2014/05/04/midi-measures/
    //A value of 480 means a quarter note has a resolution of 480 parts. An eighth note will be 240, a sixteenth 120, and so forth. It gets more interesting with things like triplets. With a higher value of 480 for the PPQ, odd time divisions can be more accurate. When a very expressive musician with strong phrasing is playing, the resulting music will sound very natural.
    // 384  = quarter note / 192 = eighth note
    UInt32 timeResolution = [self determineTimeResolutionWithTempoTrack:tempoTrack];
    
    
    MusicTimeStamp inBeats = 0;
    UInt32 inSubbeatDivisor;
    CABarBeatTime outBarBeatTime;
    MusicSequenceBeatsToBarBeatTime(seq, inBeats, timeResolution, &outBarBeatTime);
    
    // PPQ or time resolution
    NSLog(@"bar:%i, beat:%i, reserved:%i, subbeat:%i, subbeatDivisor: ( PPQ or time resolution)%i, inBeats:%f", outBarBeatTime.bar, outBarBeatTime.beat, outBarBeatTime.reserved, outBarBeatTime.subbeat, outBarBeatTime.subbeatDivisor, inBeats);
    
    
    MusicEventType eventType;
    MusicTimeStamp eventTimeStamp;
    UInt32 eventDataSize;
    const void *eventData;
    
    
    
    
    Boolean hasCurrentEvent = NO;
    MusicEventIteratorHasCurrentEvent(iterator, &hasCurrentEvent);
    while (hasCurrentEvent) {
        MusicEventIteratorGetEventInfo(iterator, &eventTimeStamp, &eventType, &eventData, &eventDataSize);
        //NSLog(@"event timeStamp %f ", eventTimeStamp);
        
        
        switch (eventType) {
            case kMusicEventType_ExtendedNote: {
                ExtendedNoteOnEvent *ext_note_evt = (ExtendedNoteOnEvent *)eventData;
                NSLog(@"extended note event, instrumentID %u", (unsigned int)ext_note_evt->instrumentID);
            }
                break;
                
            case kMusicEventType_ExtendedTempo: {
                ExtendedTempoEvent *ext_tempo_evt = (ExtendedTempoEvent *)eventData;
                NSLog(@"ExtendedTempoEvent, bpm %f", ext_tempo_evt->bpm);
            }
                break;
                
            case kMusicEventType_User: {
                MusicEventUserData *user_evt = (MusicEventUserData *)eventData;
                NSLog(@"MusicEventUserData, data length %u", (unsigned int)user_evt->length);
            }
                break;
                
            case kMusicEventType_Meta: {
                MIDIMetaEvent *meta_evt = (MIDIMetaEvent *)eventData;
                //kMusicEventType_ExtendedTempo
                UInt8 k =  meta_evt->metaEventType;
                if (k == kMusicEventType_ExtendedTempo) {
                    NSLog(@"tempo  data[0]: %d", meta_evt->data[0]);
                    NSLog(@"tempo  data[1]: %d", meta_evt->data[1]);
                    NSLog(@"tempo  data[2]: %d", meta_evt->data[2]);
                    NSLog(@"tempo  data[3]: %d", meta_evt->data[3]);
                }
                else if (k == kMusicEventType_Meta) {
                    NSLog(@"MIDIMetaEvent, detected kMusicEventType_Meta %d", meta_evt->data[1]);
                }
                else {
                    //http://ericjknapp.com/blog/2014/03/30/midi-files-and-tracks/
                    NSLog(@"MIDIMetaEvent, detected  %d", meta_evt->data[1]);
                }
            }
                break;
                
            case kMusicEventType_MIDINoteMessage: {
                MIDINoteMessage *note_evt = (MIDINoteMessage *)eventData;
                [self showNoteInformationWithNote:note_evt timestamp:eventTimeStamp sequence:seq timeResolution:2];
            }
                break;
                
            case kMusicEventType_MIDIChannelMessage: {
                MIDIChannelMessage *channel_evt = (MIDIChannelMessage *)eventData;
                NSLog(@"channel event status %X", channel_evt->status);
                
                if (channel_evt->status == (0xC0 & 0xF0)) {
                    //[self setPresetNumber:channel_evt->data1];
                }
            }
                break;
                
            case kMusicEventType_MIDIRawData: {
                MIDIRawData *raw_data_evt = (MIDIRawData *)eventData;
                NSLog(@"MIDIRawData, length %u", (unsigned int)raw_data_evt->length);
            }
                break;
                
            case kMusicEventType_Parameter: {
                ParameterEvent *parameter_evt = (ParameterEvent *)eventData;
                NSLog(@"ParameterEvent, parameterid %u", (unsigned int)parameter_evt->parameterID);
            }
                break;
                
            default:
                break;
        }
        
        MusicEventIteratorHasNextEvent(iterator, &hasCurrentEvent);
        MusicEventIteratorNextEvent(iterator);
    }
}

+ (UInt32)determineTimeResolutionWithTempoTrack:(MusicTrack)tempoTrack {
    UInt32 timeResolution = 0;
    UInt32 propertyLength = 0;
    
    MusicTrackGetProperty(tempoTrack,
                          kSequenceTrackProperty_TimeResolution,
                          NULL,
                          &propertyLength);
    
    
    MusicTrackGetProperty(tempoTrack,
                          kSequenceTrackProperty_TimeResolution,
                          &timeResolution,
                          &propertyLength);
    
    printf("propertyLength: %d\n", propertyLength);
    printf("timeResolution: %d\n", timeResolution);
    
    return timeResolution;
}

+ (void)showNoteInformationWithNote:(MIDINoteMessage *)noteMessage
                          timestamp:(MusicTimeStamp)timestamp sequence:(MusicSequence)_sequence timeResolution:(UInt32)timeResolution {
    CABarBeatTime barBeatTime;
    MusicSequenceBeatsToBarBeatTime(_sequence, timestamp, timeResolution, &barBeatTime);
    
    printf("%03d:%02d:%03d, timestamp: %5.3f, channel: %d, note: %s, duration: %.3f\n",
           barBeatTime.bar,
           barBeatTime.beat,
           barBeatTime.subbeat,
           timestamp,
           noteMessage->channel,
           noteForMidiNumber(noteMessage->note),
           noteMessage->duration
           );
}

const char *noteForMidiNumber(int midiNumber) {
    const char *const noteArraySharps[] = { "", "", "", "", "", "", "", "", "", "", "", "",
        "C0", "C#0", "D0", "D#0", "E0", "F0", "F#0", "G0", "G#0", "A0", "A#0", "B0",
        "C1", "C#1", "D1", "D#1", "E1", "F1", "F#1", "G1", "G#1", "A1", "A#1", "B1",
        "C2", "C#2", "D2", "D#2", "E2", "F2", "F#2", "G2", "G#2", "A2", "A#2", "B2",
        "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3",
        "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4",
        "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5", "A5", "A#5", "B5",
        "C6", "C#6", "D6", "D#6", "E6", "F6", "F#6", "G6", "G#6", "A6", "A#6", "B6",
        "C7", "C#7", "D7", "D#7", "E7", "F7", "F#7", "G7", "G#7", "A7", "A#7", "B7",
        "C8", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" };
    
    return noteArraySharps[midiNumber];
}

/*
+ (int)readTrackFrom:(NSData *)data into:(Song *)song atOffset:(int)offset withResolution:(int)resolution {
    int trackSize = [self readIntFrom:data offset:(offset + 4) length:4];
    offset += 8;
    int trackEnd = offset + trackSize;
    NSMutableDictionary *staffs = [NSMutableDictionary dictionary];
    Staff *extraStaff = nil;
    NSMutableDictionary *openNotes = [NSMutableDictionary dictionary];
    NSMutableDictionary *lastEventTimes = [NSMutableDictionary dictionary];
    int type, channel;
    float deltaBeats = 0;
    while (offset < trackEnd) {
        int deltaTime;
        offset += [self readVariableLengthFrom:data into:&deltaTime atOffset:offset];
        deltaBeats += (float)deltaTime / (float)resolution;
        NSLog(@"offset:%d deltaTime:%d", offset, deltaTime);
        int eventTypeAndChannel = [self readIntFrom:data offset:(offset) length:1];
        offset++;
        if (eventTypeAndChannel == 0xFF) {
            //meta event
            int metaType = [self readIntFrom:data offset:(offset) length:1];
            offset++;
            int eventLength;
            offset += [self readVariableLengthFrom:data into:&eventLength atOffset:offset];
            //TODO: process delta time
            NSString *name;
            int mpqn, num, denomPower, denom, sharpsOrFlats, minor;
            float bpm;
            Staff *staff;
            if ([staffs count] == 0) {
                if (extraStaff == nil) {
                    extraStaff = [song addStaff];
                }
                staff = extraStaff;
            }
            else {
                staff = [[staffs allValues] objectAtIndex:0];
            }
            switch (metaType) {
                case 0x03: //track name
                    name = [self readStringFrom:data range:NSMakeRange(offset, eventLength)];
                    [staff setName:name];
                    //					NSLog(name);
                    break;
                    
                case 0x51: //tempo change
                    mpqn = [self readIntFrom:data offset:(offset) length:eventLength];
                    bpm = ((float)60000000 / mpqn);
                    //TODO - get the right one based on the current time
                    [[[song tempoData] lastObject] setTempo:round(bpm)];
                    break;
                    
                case 0x58: //time signature
                    //TODO: end the current measure (by changing its time signature)
                    //this will be weird - what does it mean to change time signatures in the middle of a measure?
                    //we will need to change the current measure's time signature to make it end where it is,
                    //set the next measure's time signature so it ends where it should end, then set the specified
                    //time signature in the following measure.
                    num = [self readIntFrom:data offset:(offset) length:1];
                    denomPower = [self readIntFrom:data offset:(offset + 1) length:1];
                    denom = pow(2, denomPower);
                    int idx = ([[staff getMeasures] count] - 1);
                    if (idx > 0) {
                        [song setTimeSignature:[TimeSignature timeSignatureWithTop:num bottom:denom]
                                       atIndex:idx];
                    }
                    
                    break;
                    
                case 0x59: //key signature
                    //TODO: end the current measure (by changing its time signature)
                    sharpsOrFlats = [self readIntFrom:data offset:(offset) length:1];
                    minor = [self readIntFrom:data offset:(offset + 1) length:1];
                    if (sharpsOrFlats >= 0) {
                        [[[staff getMeasures] lastObject] setKeySignature:[KeySignature getSignatureWithSharps:sharpsOrFlats minor:(minor > 0)]];
                    }
                    else {
                        [[[staff getMeasures] lastObject] setKeySignature:[KeySignature getSignatureWithFlats:-sharpsOrFlats minor:(minor > 0)]];
                    }
                    break;
            }
            offset += eventLength;
        }
        else {
            //MIDI event
            int param1;
            if (eventTypeAndChannel & 0x80) {
                type = eventTypeAndChannel & 0xF0;
                channel = eventTypeAndChannel & 0x0F;
                param1 = [self readIntFrom:data offset:(offset) length:1];
                offset++;
            }
            else {
                param1 = eventTypeAndChannel;
            }
            NSNumber *ch = [NSNumber numberWithInt:channel];
            int param2 = [self readIntFrom:data offset:(offset) length:1];
            offset++;
            if (type == 0x80 || type == 0x90) {
                Staff *staff;
                if ([staffs count] == 0 && extraStaff != nil) {
                    staff = extraStaff;
                    [staff setChannel:(channel + 1)];
                    [staffs setObject:staff forKey:ch];
                }
                else {
                    staff = [staffs objectForKey:ch];
                    if (staff == nil) {
                        staff = [song addStaff];
                        [staff setChannel:(channel + 1)];
                        [staffs setObject:staff forKey:ch];
                    }
                }
                NSMutableArray *openNoteArray = [openNotes objectForKey:ch];
                if (openNoteArray == nil) {
                    openNoteArray = [NSMutableArray array];
                    [openNotes setObject:openNoteArray forKey:ch];
                }
                Note *newNote;
                Measure *measure;
                KeySignature *keySig;
                int pitch, octave, acc;
                NSNumber *prevAcc;
                NSEnumerator *openNotesEnum;
                NSDictionary *accidentals;
                id openNote;
                NSNumber *lastEventTime = [lastEventTimes objectForKey:ch];
                float lastEvent;
                if (lastEventTime == nil) {
                    [lastEventTimes setObject:[NSNumber numberWithFloat:0] forKey:ch];
                    lastEvent = 0;
                }
                else {
                    lastEvent = [lastEventTime floatValue];
                }
                measure = [staff getLastMeasure];
                if (deltaBeats > 0) {
                    if ([openNoteArray count] == 0) {
                        //add rests
                        float restsToCreate = deltaBeats * 3 / 4;
                        while (restsToCreate > 0) {
                            Rest *rest = [[Rest alloc] initWithDuration:0 dotted:NO onStaff:staff];
                            if (![rest tryToFill:restsToCreate]) {
                                break;
                            }
                            restsToCreate -= [rest getEffectiveDuration];
                            NSArray *arr = [measure.notes copy];
                            [measure addNote:rest atIndex:([arr count] - 0.5) tieToPrev:NO];
                            measure = [staff getLastMeasure];
                        }
                    }
                    else {
                        //increase duration of open notes
                        openNotesEnum = [openNoteArray objectEnumerator];
                        while (openNote = [openNotesEnum nextObject]) {
                            [openNote tryToFill:([openNote getEffectiveDuration] + deltaBeats * 3 / 4)];
                        }
                    }
                    deltaBeats = 0;
                }
                keySig = [measure getEffectiveKeySignature];
                switch (type) {
                    case 0x80: //note off
                        openNotesEnum = [[openNoteArray copy] objectEnumerator];
                        while (openNote = [openNotesEnum nextObject]) {
                            if ([openNote getEffectivePitchWithKeySignature:keySig priorAccidentals:[measure getAccidentalsAtPosition:[measure.notes count]]] == param1) {
                                [openNoteArray removeObject:openNote];
                            }
                        }
                        break;
                        
                    case 0x90: //note on
                        pitch = [keySig positionForPitch:(param1 % 12) preferAccidental:0];
                        octave = (param1 / 12);
                        acc = [keySig accidentalForPitch:(param1 % 12) atPosition:pitch];
                        if (acc == NO_ACC) {
                            accidentals = [measure getAccidentalsAtPosition:[measure.notes count]];
                            prevAcc = [accidentals objectForKey:[NSNumber numberWithInt:(octave * 7 + pitch)]];
                            if (prevAcc != nil && [prevAcc intValue] != NO_ACC) {
                                acc = NATURAL;
                            }
                        }
                        newNote = [[Note alloc] initWithPitch:pitch octave:octave duration:0 dotted:NO
                                                   accidental:acc onStaff:staff];
                        if ([openNoteArray count] != 0) {
                            Chord *newChord = [[Chord alloc] initWithStaff:staff withNotes:[NSMutableArray arrayWithObject:newNote]];
                            openNotesEnum = [openNoteArray objectEnumerator];
                            BOOL replacing = NO;
                            while (openNote = [openNotesEnum nextObject]) {
                                if ([openNote getDuration] > 0) {
                                    NSArray *notes;
                                    if ([openNote respondsToSelector:@selector(getNotes)]) {
                                        notes = [openNote getNotes];
                                    }
                                    else {
                                        notes = [NSArray arrayWithObject:openNote];
                                    }
                                    NSEnumerator *openNoteEnum = [notes objectEnumerator];
                                    id subnote;
                                    while (subnote = [openNoteEnum nextObject]) {
                                        Note *noteCopy = [subnote copy];
                                        [noteCopy setDuration:0];
                                        [noteCopy setDottedSilently:NO];
                                        [subnote tieTo:noteCopy];
                                        [noteCopy tieFrom:subnote];
                                        [newChord addNote:subnote];
                                    }
                                }
                                else {
                                    replacing = YES;
                                    [newChord addNote:openNote];
                                }
                            }
                            [openNoteArray addObject:newNote];
                            newNote = newChord;
                            if (replacing) {
                                [staff removeLastNote];
                            }
                        }
                        else {
                            [openNoteArray addObject:newNote];
                        }
                        [measure addNote:newNote atIndex:([measure.notes count] - 0.5) tieToPrev:NO];
                        break;
                }
                [lastEventTimes setObject:[NSNumber numberWithFloat:(lastEvent + deltaBeats)] forKey:ch];
            }
        }
    }
    NSEnumerator *staffsEnum = [[[song staffs] copy]objectEnumerator];
    id staff;
    while (staff = [staffsEnum nextObject]) {
        NSArray *measures = [staff getMeasures];
        NSLog(@"measure:%@", measures);
        Measure *measure = [measures objectAtIndex:0];
        if ([measures count] > 1 || ([measures count] == 1 && [measure.notes count] > 0)) {
            NSEnumerator *measuresEnum = [measures objectEnumerator];
            id measure;
            while (measure = [measuresEnum nextObject]) {
                //                [measure grabNotesFromNextMeasure];
                //                [measure refreshNotes:nil];
            }
        }
        else {
            [song removeStaff:staff];
        }
    }
    return trackSize + 8;
}

+ (void)readSong:(Song *)song fromMIDI:(NSData *)data {
    int format = [self readIntFrom:data offset:(8) length:2];
    if (format > 1) {
        NSException *e = [NSException exceptionWithName:@"MIDIException" reason:@"MIDI file was an unsupported format type, must be 0 or 1." userInfo:nil];
        @throw e;
    }
    int numTracks = [self readIntFrom:data offset:(10) length:2];
    int resolution;
    int rawRes = [self readIntFrom:data offset:(12) length:2];
    if (!(rawRes & 0x8000)) {
        resolution = rawRes;
    }
    else {
        NSException *e = [NSException exceptionWithName:@"MIDIException" reason:@"MIDI file specifies resolution in frames per second.  Import of this type of file has not yet been implemented." userInfo:nil];
        @throw e;
    }
    int i, offset = 14;
    for (i = 0; i < numTracks; i++) {
        NSLog(@"resolution:%d", resolution);
        offset += [self readTrackFrom:data into:song atOffset:offset withResolution:resolution];
    }
    while ([[song staffs] count] > 1) {
        [song removeStaff:[[song staffs] lastObject]];
    }
}
*/
@end
