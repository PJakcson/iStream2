# UPnPTest #

UPnPTest allows you to stream your media onto your big TV screen with no configuration at all! Just throw in some files and UPnPTest will do the rest! UPnPTest supports a vast number of media formats and playback devices: From modern SmartTVs via set-top boxes or network-enabled stereos through to software solutions (e.g. Kodi or Plex) running on an HTPC, everything is possible.

*** IMPORTANT NOTES ***: Due to the nature of the underlying protocols, device vendors have a big area of freedom in implementing these streaming features. Therefor it cannot be guaranteed that UPnPTest fully supports your device. Please download the free trail version LINK before buying to see if everything works!
Supported file formats are determined by your playback device, not by UPnPTest. Please consult your device's manual if you are uncertain.
Playback performance is determined by the speed of your network connection, not by UPnPTest. WiFi connections might be too slow for high definition content.

### Main Features ###

* Super-fast discovery of all compatible media renderers on your network!
* Play any of your media files on your big TV screen with just one mouse click!
* Supports automatic playback of multiple files (e.g. image slideshows or multiple parts of a TV series)
* Supports fast forwarding and seeking of video and audio files on most devices
* 100% pure Cocoa code for best performance and user experience


# FAQ #

## UPnPTest doesn't discover any devices. What's wrong? ##
This could have multiple reasons:
+ Your computers firewall is blocking incoming and/or outgoing communication. Try adding an exception rule for UPnPTest, especially port 1900 UDP.
+ Your router is blocking multicast pakets. This happens especially when your computer is on WiFi and your playback device on ethernet (or vice versa). On some routers this can be solved by changing some settings (e.g. Multicast or WMM), on others you can't do anything.
+ Your device just isn't supported.

## Filetype .xyz doesn't play on my device. ##
UPnPTest supports all filetypes which are natively supported by your playback device. There is no transcoding at the moment, so you would have to convert the file into a compatible format beforehand. However, if you are sure that your media renderer supports this filetype (e.g. because the file can be played from USB), please contact support.

## My video playback is sluggish, what should I do? ##
The performance of the data transfer is solely determined by the performance of your network connection, UPnPTest has NO impact on it. WiFi connections might be too slow for high definition content, try optimizing it or switch over to a wired connection.

## How to start an image slideshow? ##
Just drag multiple image files onto UPnPTest. They will be played automatically with 10 seconds delay.

## How to pause video playback or an image slideshow? ##
Just click onto the TV icon or use your TVs remote.