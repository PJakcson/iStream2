# iStream #

iStream allows you to stream your media onto your big TV screen with no configuration at all! Just throw in some files and iStream will do the rest! iStream supports a vast number of media formats and playback devices: From modern SmartTVs via set-top boxes or network-enabled stereos through to software solutions (e.g. Kodi or Plex) running on an HTPC, everything is possible.

Use it to get a movie on your big screen, your music to your stereo or to show an image slideshow to your friends. Compatible devices will be detected automatically, you don't have to care about anything.

### Main Features ###

* Super-fast discovery of all compatible media renderers on your network!
* Play any of your media files on your big TV screen with just one mouse click!
* Supports automatic playback of multiple files (e.g. image slideshows or multiple parts of a TV series)
* Supports fast forwarding and seeking of video and audio files on most devices
* 100% pure Cocoa code for best performance and user experience

# Requirements #

* OS X 10.7+
* UPnP/DLNA compliant media renderer (SmartTV, Set-Top Box, AV-Receiver, Bluray-Player, HTPC, ...)

# Credits #

* Development, UI, Icons: Florian Bethke
* [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket), [CocoaHTTPServer](https://github.com/robbiehanson/CocoaHTTPServer) and [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) by Robbie Hanson
* [XMLDictionary](https://github.com/nicklockwood/XMLDictionary) by Nick Lockwood
* [Sparkle](http://sparkle-project.org)

# Donation #

Do you like the project? If you wanna buy me a coffee, feel free to do so: [![donation](http://www.paypal.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id= 63CMERZ94YUFL)

# License #
Copyright (c) 2015, Florian Bethke
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# FAQ #

## Is my TV / set-top box / console / AV-receiver supported? #

If it has networking functionalities and confirmes to the UPnP standard, it is likely to be supported. Just try it out, iStream is free!

## iStream doesn't discover any devices. What's wrong? ##
This could have multiple reasons:

+ Your computers firewall is blocking incoming and/or outgoing communication. Try adding an exception rule for iStream, especially port 1900 UDP.
+ Your router is blocking multicast pakets. This happens especially when your computer is on WiFi and your playback device on ethernet (or vice versa). On some routers this can be solved by changing some settings (e.g. Multicast or WMM), on others you can't do anything.
+ Your device just isn't supported.

## Filetype .xyz doesn't play on my device. ##

iStream supports all filetypes which are natively supported by your playback device. There is no transcoding at the moment, so you would have to convert the file into a compatible format beforehand. However, if you are sure that your media renderer supports this filetype (e.g. because the file can be played from USB), please report an issue in the issue tracker here on Bitbucket.

 ## An advertised feature (e.g. fast-forwarding, seeking, queued playback, image slideshows...) doesn't work. Why? ##

Device vendors have a great amount of freedom in implementing the streaming protocols. Additionally, many devices have bugs in their implementations which make them behave incorrectly. This makes it quite difficult to fully support all of them at once. If you want to help improving iStream, please don't hesitate to open up an issue: If your problem can be found, your device will be fully supported in the next release.

## My video playback is sluggish, what should I do? ##
The performance of the data transfer is solely determined by the performance of your network connection, iStream has NO impact on it. WiFi connections might be too slow for high definition content, try optimizing it or switch over to a wired connection.

## How to start an image slideshow? ##
Just drag multiple image files onto iStream. They will be played automatically with 10 seconds delay.

## How to pause video playback or an image slideshow? ##
Just click onto the TV icon or use your TVs remote.