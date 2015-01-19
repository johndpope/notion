
This objective C library is a reboot of fantastic work done by Gus Prevas
https://github.com/kprevas in SenorStaff osx app. 

I've included the Señor Staff app as a reference. 
It can input notes into staffs and supports playback to any MIDI device.

https://raw.githubusercontent.com/johndpope/notion/master/justForShow.png


The OSXApp-Reference - Non ARC. 
The models have ui logic / classes. This predates ios operating system.

Notion - is an attempt to reboot library - reusing the core models which have been ARC'd.
Currently its loading a midi file and parsing this into components > 
Staffs / Measures / Notes + Rests.


Processing this midi .....
<img src="https://raw.githubusercontent.com/johndpope/notion/master/justForShow.png"/>



 will give you this > 

	2015-01-19 14:37:01.559 Notion[23662:2258719] staff:<Staff: 0x618000082080>
	2015-01-19 14:37:01.559 Notion[23662:2258719] measure:<Measure: 0x6180001404d0>
	2015-01-19 14:37:01.559 Notion[23662:2258719] rest class:<Rest: 0x600000021920>
	2015-01-19 14:37:01.559 Notion[23662:2258719] rest class:<Rest: 0x600000025500>
	2015-01-19 14:37:01.559 Notion[23662:2258719] rest class:<Rest: 0x608000028540>
	2015-01-19 14:37:01.559 Notion[23662:2258719] Note class:<Note: 0x60800006fac0>
	2015-01-19 14:37:01.559 Notion[23662:2258719] measure:<Measure: 0x618000140580>
	2015-01-19 14:37:01.560 Notion[23662:2258719] rest class:<Rest: 0x618000030fe0>
	2015-01-19 14:37:01.560 Notion[23662:2258719] Note class:<Note: 0x6180002607c0>
	2015-01-19 14:37:01.560 Notion[23662:2258719] rest class:<Rest: 0x6180000309e0>
	2015-01-19 14:37:01.560 Notion[23662:2258719] Note class:<Note: 0x6180002608c0>
	2015-01-19 14:37:01.560 Notion[23662:2258719] Note class:<Note: 0x618000260880>
	2015-01-19 14:37:01.560 Notion[23662:2258719] measure:<Measure: 0x600000142cb0>
	2015-01-19 14:37:01.560 Notion[23662:2258719]  class:Chord
	2015-01-19 14:37:01.560 Notion[23662:2258719] Note class:<Note: 0x600000066e80>
	2015-01-19 14:37:01.560 Notion[23662:2258719] Note class:<Note: 0x600000066f00>
	2015-01-19 14:37:01.560 Notion[23662:2258719] Note class:<Note: 0x6180002609c0>

this have ties / durations etc



	"<measure number=\"1\">
	<attributes>
	<divisions>48</divisions>
	<key>
	<fifths>0</fifths>
	<mode>major</mode>
	</key>
	<clef>
	<sign>G</sign>
	<line>2</line>
	</clef>
	</attributes>
	<sound tempo=\"120\"/>
	<note>/n<rest/>
	<duration>24</duration>
	</note>
	<note>/n<rest/>
	<duration>8</duration>
	<time-modification>
	<actual-notes>3</actual-notes>
	<normal-notes>2</normal-notes>
	</time-modification>
	</note>
	<note>/n<rest/>
	<duration>3</duration>
	</note>
	<note>
	<pitch>
	<step>f</step>
	<octave>5</octave>
	</pitch>
	<duration>8</duration>
	<time-modification>
	<actual-notes>3</actual-notes>
	<normal-notes>2</normal-notes>
	</time-modification>
	<notations>
	</notations>
	</note>
	</measure>
	",
	"<measure number=\"2\">
	<attributes>
	</attributes>
	<note>/n<rest/>
	<duration>12</duration>
	</note>
	<note>
	<pitch>
	<step>a</step>
	<octave>5</octave>
	</pitch>
	<duration>8</duration>
	<time-modification>
	<actual-notes>3</actual-notes>
	<normal-notes>2</normal-notes>
	</time-modification>
	<notations>
	</notations>
	</note>
	<note>/n<rest/>
	<duration>12</duration>
	</note>
	<note>
	<pitch>
	<step>b</step>
	<octave>5</octave>
	</pitch>
	<duration>8</duration>
	<time-modification>
	<actual-notes>3</actual-notes>
	<normal-notes>2</normal-notes>
	</time-modification>
	<notations>
	</notations>
	</note>
	<note>
	<pitch>
	<step>c</step>
	<octave>6</octave>
	</pitch>
	<duration>6</duration>
	<notations>
	</notations>
	</note>
	</measure>
	",
	"<measure number=\"3\">
	<attributes>
	</attributes>
	<note>
	<pitch>
	<step>e</step>
	<octave>6</octave>
	</pitch>
	<notations>
	</notations>
	</note>
	<note>
	<chord/>
	<pitch>
	<step>d</step>
	<octave>6</octave>
	</pitch>
	<duration>12</duration>
	<notations>
	</notations>
	</note>
	<note>
	<pitch>
	<step>f</step>
	<octave>6</octave>
	</pitch>
	<duration>8</duration>
	<time-modification>
	<actual-notes>3</actual-notes>
	<normal-notes>2</normal-notes>
	</time-modification>
	<notations>
	</notations>
	</note>
	<note>
	<pitch>
	<step>g</step>
	<octave>6</octave>
	</pitch>
	<duration>8</duration>
	<time-modification>
	<actual-notes>3</actual-notes>
	<normal-notes>2</normal-notes>
	</time-modification>
	<notations>
	</notations>
	</note>
	<note>
	<pitch>
	<step>a</step>
	<octave>6</octave>
	</pitch>
	<duration>8</duration>
	<time-modification>
	<actual-notes>3</actual-notes>
	<normal-notes>2</normal-notes>
	</time-modification>
	<notations>
	</notations>
	</note>
	</measure>
	"


What's next? 
Join the project - start chipping away at recreating the ui


known regression
the MusicXML parts of app were overiding the description method in models. 
I commented these parts out - it would be good to get this working again. 
http://www.musicxml.com/wp-content/uploads/2012/12/musicxml-tutorial.pdf


If you would like to contribute to project - feel free to ask to be a collaborator. 
Please use uncrustify xcode plugin to conform code standards and simplify merging->
https://github.com/bengardner/uncrustify


Be sure to keep an eye out for the C++ Ascograph with libmusicxml framework + ios sample app by Thomas Coffy.
https://github.com/k4rm/AscoGraph

http://forumnet.ircam.fr/product/antescofo/



Thanks to Gus - he has kindly reworked Señor Staff from GPL license to 
MIT License. https://code.google.com/p/senorstaff/



![alt tag](https://raw.githubusercontent.com/johndpope/notion/master/OSXApp-Reference/img.png)

Downloads
https://code.google.com/p/senorstaff/downloads/detail?name=SenorStaff0.8.3.dmg

