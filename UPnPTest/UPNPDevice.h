//
//  UPNPDevice.h
//  UPnPTest
//
//  Created by Florian Bethke on 22.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UPNPService;

@interface UPNPDevice : NSObject

@property (nonatomic, strong) NSString *UDN;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *friendlyName;
@property (nonatomic, strong) NSMutableDictionary *services;
@property (nonatomic, strong) NSArray *protocols;
@property (nonatomic) bool validDevice;

-(void)printInfo;
-(void)printInfoVerbose;
-(void)addService:(UPNPService *)service;
-(void)updateProtocolInfo;
-(bool)checkValidity;
-(bool)playFile:(NSString *)filePath atAddress:(NSString *)address;

@end
