#import "JPNoteEvent.h"

@implementation JPNoteEvent
//
- (NSString *)description {
    return [NSString stringWithFormat:@"beat=%f, note=%u, velocity=%u, duration:%f channel:%d timestamp :%f", _beat, _note, _velocity, _duration, _channel, _timeStamp];
}

- (NSString *)ascii {
    NSString *s = [NSString string];
    
    NSString *notestr = [NSString stringWithFormat:@"%c", self.note];
    s = [s stringByAppendingString:notestr];
    
    return s;
}

- (id)copyWithZone:(NSZone *)zone {
    JPNoteEvent *result = [[JPNoteEvent alloc] init];
    result.beat = self.beat;
    result.note = self.note;
    result.velocity = self.velocity;
    result.duration = self.duration;
    result.bar = self.bar;
    result.beat = self.beat;
    result.trackNumer = self.trackNumer;
    result.channel = self.channel;
    result.timeStamp = self.timeStamp;
    result.counterPointType = self.counterPointType;
    result.targetFilter = self.targetFilter;
    
    return result;
}

-(void)setMessageType:(int16_t)messageType{
    if (messageType == ControlChange) {
        _msgType = ControlChange;
        return;
    }
    if (messageType == ProgramChange) {
        _msgType = ProgramChange;
        return;
    }
    if (messageType == PitchWheel) {
        _msgType = PitchWheel;
        return;
    }
    if (messageType == DataEntry) {
        _msgType = DataEntry;
        return;
    }
    if (messageType == AdaptiveChordVoicing) {
        _msgType = AdaptiveChordVoicing;
        return;
    }
    
    if (messageType >= 0 && messageType <= 127)
        _msgType = Note;
    
    
}
@end
