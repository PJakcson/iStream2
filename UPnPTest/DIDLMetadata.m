//
//  DIDLMetadata.m
//  UPnPTest
//
//  Created by Florian Bethke on 22.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import "DIDLMetadata.h"
#import <CoreServices/CoreServices.h>

@implementation DIDLMetadata

+(NSString *)metadataWithURI:(NSString *)URI title:(NSString *)title protocol:(NSString *)protocol size:(NSString *)size class:(NSString *)upnpclass
{
    // Create DIDL metadata
    NSMutableString *meta = [[NSMutableString alloc] init];
    [meta appendString:@"<DIDL-Lite xmlns=\"urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:upnp=\"urn:schemas-upnp-org:metadata-1-0/upnp/\">"];
    [meta appendString:@"<item id=\"1\" parentID=\"-1\" restricted=\"1\" refID=\"1\">"];
    [meta appendFormat:@"<upnp:class>%@</upnp:class>", upnpclass];
    [meta appendFormat:@"<res size=\"%@\" protocolInfo=\"%@\">", size, protocol];
    [meta appendString: URI];
    [meta appendString:@"</res>"];
    [meta appendFormat:@"<dc:title>%@</dc:title>", title];
    [meta appendString:@"</item>"];
    [meta appendString:@"</DIDL-Lite>"];
    
    // Escape characters
    NSString *esc = [meta escapeHTMLCharacters];
    
    return esc;
}

+(NSString *)metadataWithFile:(NSString *)filepath address:(NSString *)address
{
    // Get title
    NSString *title = [[filepath componentsSeparatedByString:@"/"] lastObject];
    
    // Get filesize
    NSFileManager *man = [NSFileManager defaultManager];
    NSError *err;
    NSDictionary *attrs = [man attributesOfItemAtPath:filepath error:&err];
    if (err)
        return @"";
    NSUInteger filesize = [attrs fileSize];
    NSString *size = [NSString stringWithFormat:@"%tu", filesize];
    
    // Get MIME type
    NSString *MIME = [DIDLMetadata getMIMEType:filepath];
    
    // Build protocol string
    // TODO: Add DLNA.ORG_PN
    NSString *protocol = [NSString stringWithFormat:@"http-get:*:%@:DLNA.ORG_OP=01;DLNA.ORG_CI=0", MIME];
    
    // Get UPnP class
    NSString *class = [DIDLMetadata getUPNPClass:MIME];
    
    // Build DIDL metadata
    NSString *meta = [DIDLMetadata metadataWithURI:address title:title protocol:protocol size:size class:class];

    return meta;
}

+(NSString *)getMIMEType:(NSString *)filepath
{
    // Workaround for .mkv
    NSString *fileExt = [[filepath componentsSeparatedByString:@"."] lastObject];
    if ([fileExt isEqualToString:@"mkv"])
        return @"video/x-matroska";
    
    // Get MIME type for standard files
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[filepath pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    
    // TODO: Workaround for other unknown files
    
    return (__bridge_transfer NSString *)MIMEType;
}

+(NSString *)getUPNPClass:(NSString *)MIMEType
{
    NSString *objectType = [[MIMEType componentsSeparatedByString:@"/"] firstObject];
    
    return [NSString stringWithFormat:@"object.item.%@Item", objectType];
}

@end

// Category of NSString for escaping HTML characters
@implementation NSString (NSStringHTML)

-(NSString *)escapeHTMLCharacters
{
    NSString *esc = [self stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    esc = [esc stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    esc = [esc stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    
    return esc;
}

@end

