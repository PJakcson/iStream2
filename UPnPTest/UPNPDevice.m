//
//  UPNPDevice.m
//  UPnPTest
//
//  Created by Florian Bethke on 22.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import "UPNPDevice.h"
#import "UPNPService.h"
#import "CMService.h"
#import "AVTService.h"
#import "DIDLMetadata.h"


@implementation UPNPDevice

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _services = [[NSMutableDictionary alloc] init];
        _validDevice = false;   // Don't know if it's a valid device yet
    }
    return self;
}

-(void)printInfo
{
    NSLog(@"Name: %@", _friendlyName);
    NSLog(@"Location: %@", _location);
    NSLog(@"Valid: %@", _validDevice ? @"Yes" : @"No");
    NSLog(@"Services: %@", _services);
}

-(void)addService:(UPNPService *)service
{
    NSString *serviceName = NSStringFromClass([(id)service class]);
    [_services setObject:service forKey:serviceName];
}

-(void)updateProtocolInfo
{
    _protocols = [[_services objectForKey:@"CMService"] getProtocolInfo];
//    NSLog(@"%@", _protocols);
}

-(bool)checkValidity
{
    // TODO: MediaClient?
    if (([_services objectForKey:@"CMService"] != nil) && ([_services objectForKey:@"AVTService"] != nil))
    {
        _validDevice = true;
        
        // Fix service URLs if neccessary
        for (NSString *serviceName in _services)
        {
            UPNPService *service = [_services objectForKey:serviceName];
            if ([[[service controlURL] substringToIndex:1] isEqualToString:@"/"])
                [service setControlURL:[[service controlURL] substringFromIndex:1]];
            if ([[[service eventURL] substringToIndex:1] isEqualToString:@"/"])
                [service setEventURL:[[service eventURL] substringFromIndex:1]];
        }
    }
    
    return _validDevice;
}

-(bool)playFile:(NSString *)filePath atAddress:(NSString *)address
{
    // TODO: Check if file type is supported by device
    
    if (!_validDevice)
        return false;
    
    // Stop current playback
    // TODO: Ggf. Fall 718 abfangen
//    if (![[_services objectForKey:@"AVTService"] stop:@"0"])
//        return false;
    
    // Create DIDL metadata
    NSString *meta = [DIDLMetadata metadataWithFile:filePath address:address];
    
    // TODO: SetPlayMode
    // Send URI to UPnP device
    if (![[_services objectForKey:@"AVTService"] setMediaURI:address MetaData:meta ID:@"0"])
        return false;
    
    // Start playback
    if (![[_services objectForKey:@"AVTService"] play:@"0"])
        return false;
    
    return true;
}

-(void)printInfoVerbose
{
    NSLog(@"Name: %@", _friendlyName);
    NSLog(@"Location: %@", _location);
    NSLog(@"Valid: %@", _validDevice ? @"Yes" : @"No");
    NSLog(@"Services: %@", _services);
    NSLog(@"Protocols: %@", _protocols);
    NSLog(@"%@, ", [[_services objectForKey:@"CMService"] getConnectionIDs]);
    NSLog(@"%@, ", [[_services objectForKey:@"AVTService"] getMediaInfo:@"0"]);
    NSLog(@"%@, ", [[_services objectForKey:@"AVTService"] getTransportInfo:@"0"]);
    NSLog(@"%@, ", [[_services objectForKey:@"AVTService"] getTransportSettings:@"0"]);
    NSLog(@"%@, ", [[_services objectForKey:@"AVTService"] getDeviceCapabilities:@"0"]);
    NSLog(@"%@, ", [[_services objectForKey:@"AVTService"] getPositionInfo:@"0"]);
}

@end
