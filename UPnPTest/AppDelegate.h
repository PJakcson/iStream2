//
//  AppDelegate.h
//  UPnPTest
//
//  Created by Florian Bethke on 19.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSDPRequest.h"

@class SSDPRequest;

@interface AppDelegate : NSObject <NSApplicationDelegate, SSDPRequestProtocol, NSTableViewDataSource>{
    SSDPRequest *ssdp;
}

@property (atomic, strong) NSMutableDictionary *upnpDevices;
@property (atomic, strong) NSMutableArray *udnList;

- (void)playFile:(NSString *)filePath;
- (void)addFiles:(NSArray *)files;

@end

