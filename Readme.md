
This objective C library is a reboot of fantastic work done by Gus Prevas
https://github.com/kprevas in SenorStaff osx app. 

I've included the Señor Staff app as a reference. 
It can input notes into staffs and supports playback to any MIDI device.


The OSXApp-Reference - Non ARC. 
The models have ui logic / classes. This predates ios operating system.

Notion - is an attempt to reboot library - reusing the core models which have been ARC'd.
Currently its loading a midi file and parsing this into components > 
Staffs / Measures / Notes + Rests.

Processing a midi will give you this > 

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


What's next? 
Join the project - start chipping away at recreating the ui

Be sure to keep an eye out for the C++ Ascograph with libmusicxml framework + ios sample app by Thomas Coffy.
https://github.com/k4rm/AscoGraph

http://forumnet.ircam.fr/product/antescofo/



Thanks to Konstantine - he has kindly reworked Señor Staff from GPL license to Mite
MIT License. https://code.google.com/p/senorstaff/



![alt tag](https://raw.githubusercontent.com/johndpope/notion/master/OSXApp-Reference/img.png)

Downloads
https://code.google.com/p/senorstaff/downloads/detail?name=SenorStaff0.8.3.dmg

