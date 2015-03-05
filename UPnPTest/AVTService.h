//
//  AVTService.h
//  UPnPTest
//
//  Created by Florian Bethke on 22.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import "UPNPService.h"

@interface AVTService : UPNPService

-(bool)play:(NSString *)instanceID;
-(bool)pause:(NSString *)instanceID;
-(bool)stop:(NSString *)instanceID;
-(bool)next:(NSString *)instanceID;
-(bool)previous:(NSString *)instanceID;
-(bool)seek:(NSString *)instanceID Unit:(NSString *)unit Target:(NSString *)target;
-(NSDictionary *)getMediaInfo:(NSString *)instanceID;
-(NSDictionary *)getTransportInfo:(NSString *)instanceID;
-(NSDictionary *)getTransportSettings:(NSString *)instanceID;
-(NSDictionary *)getPositionInfo:(NSString *)instanceID;
-(NSDictionary *)getDeviceCapabilities:(NSString *)instanceID;
-(bool)setMediaURI:(NSString *)URI MetaData:(NSString *)meta ID:(NSString *)instanceID;
-(bool)setNextMediaURI:(NSString *)URI MetaData:(NSString *)meta ID:(NSString *)instanceID;

@end
