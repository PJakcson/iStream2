//
//  DIDLMetadata.h
//  UPnPTest
//
//  Created by Florian Bethke on 22.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DIDLMetadata : NSObject

+(NSString *)metadataWithURI:(NSString *)URI title:(NSString *)title protocol:(NSString *)protocol size:(NSString *)size class:(NSString *)upnpclass;
+(NSString *)metadataWithFile:(NSString *)filepath address:(NSString *)address;

@end


// Category of NSString for escaping HTML characters
@interface NSString (NSStringHTML)

-(NSString *)escapeHTMLCharacters;

@end