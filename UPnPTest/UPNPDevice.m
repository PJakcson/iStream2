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
#import "GlobalLogging.h"

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
    DDLogInfo(@"Name: %@", _friendlyName);
    DDLogInfo(@"Location: %@", _location);
    DDLogInfo(@"Valid: %@", _validDevice ? @"Yes" : @"No");
    DDLogInfo(@"Services: %@", _services);
}

-(void)addService:(UPNPService *)service
{
    NSString *serviceName = NSStringFromClass([(id)service class]);
    [_services setObject:service forKey:serviceName];
}

-(void)updateProtocolInfo
{
    _protocols = [[_services objectForKey:@"CMService"] getProtocolInfo];
    DDLogVerbose(@"Protocols: %@", _protocols);
}

-(bool)checkValidity
{
    // Check if neccessary service are available
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
            if ([[[service SCPDURL] substringToIndex:1] isEqualToString:@"/"])
                [service setSCPDURL:[[service SCPDURL] substringFromIndex:1]];
        }
        
        // Check AVTService.SCPD
        [[_services objectForKey:@"AVTService"] checkSCPDURL];
    
        if ([[_services objectForKey:@"AVTService"] hasNextURI])
            _deviceDescription = @"Device is fully supported!";
        else
            _deviceDescription = @"Device is not fully supported. Queueing and image slideshows might not work properly.";
    }
    
    return _validDevice;
}

-(bool)playFile:(NSString *)filePath atAddress:(NSString *)address
{
    // TODO: Check if file type is supported by device
    
    if (!_validDevice)
        return false;
    
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

-(bool)nextFile:(NSString *)filePath atAddress:(NSString *)address
{
    // TODO: Check if file type is supported by device
    
    if (!_validDevice)
        return false;
    
    // Create DIDL metadata
    NSString *meta = [DIDLMetadata metadataWithFile:filePath address:address];
    
    // Send URI to UPnP device
    if (![[_services objectForKey:@"AVTService"] setNextMediaURI:address MetaData:meta ID:@"0"])
        return false;
    
    return true;
}

-(void)printInfoVerbose
{
    DDLogVerbose(@"Name: %@", _friendlyName);
    DDLogVerbose(@"Location: %@", _location);
    DDLogVerbose(@"Valid: %@", _validDevice ? @"Yes" : @"No");
    DDLogVerbose(@"Services: %@", _services);
    DDLogVerbose(@"Protocols: %@", _protocols);
    DDLogVerbose(@"%@, ", [[_services objectForKey:@"CMService"] getConnectionIDs]);
    DDLogVerbose(@"%@, ", [[_services objectForKey:@"AVTService"] getMediaInfo:@"0"]);
    DDLogVerbose(@"%@, ", [[_services objectForKey:@"AVTService"] getTransportInfo:@"0"]);
    DDLogVerbose(@"%@, ", [[_services objectForKey:@"AVTService"] getTransportSettings:@"0"]);
    DDLogVerbose(@"%@, ", [[_services objectForKey:@"AVTService"] getDeviceCapabilities:@"0"]);
    DDLogVerbose(@"%@, ", [[_services objectForKey:@"AVTService"] getPositionInfo:@"0"]);
}

@end
