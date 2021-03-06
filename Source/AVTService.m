//
//  AVTService.m
//  UPnPTest
//
//  Created by Florian Bethke on 22.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import "AVTService.h"
#import "UPNPService.h"
#import "XMLDictionary.h"
#import "GlobalLogging.h"

@implementation AVTService

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _hasNextURI = false;
    }
    return self;
}

-(bool)play:(NSString *)instanceID
{
    NSString *soapAction = @"Play";
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:instanceID,@"InstanceID",@"1",@"Speed", nil];
    NSData *returnData;
    if ([self action:soapAction parameters:params returnValues:&returnData])
        return false;
    
//    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
//    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];
//
//    NSLog(@"%@", dict);
    
    return true;
}

-(bool)pause:(NSString *)instanceID
{
    NSString *soapAction = @"Pause";
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:instanceID,@"InstanceID", nil];
    NSData *returnData;
    if ([self action:soapAction parameters:params returnValues:&returnData])
        return false;
    
    //    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    //    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];
    //
    //    NSLog(@"%@", dict);
    
    return true;
}

-(bool)stop:(NSString *)instanceID
{
    NSString *soapAction = @"Stop";
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:instanceID,@"InstanceID", nil];
    NSData *returnData;
    if ([self action:soapAction parameters:params returnValues:&returnData])
        return false;
    
    //    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    //    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];
    //
    //    NSLog(@"%@", dict);
    
    return true;
}

-(bool)seek:(NSString *)instanceID Unit:(NSString *)unit Target:(NSString *)target
{
    NSString *soapAction = @"Seek";
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:instanceID,@"InstanceID",unit,@"Unit",target,@"Target", nil];
    NSData *returnData;
    if ([self action:soapAction parameters:params returnValues:&returnData])
        return false;
    
    //    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    //    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];
    //
    //    NSLog(@"%@", dict);
    
    return true;
}

-(bool)next:(NSString *)instanceID
{
    NSString *soapAction = @"Next";
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:instanceID,@"InstanceID", nil];
    NSData *returnData;
    if ([self action:soapAction parameters:params returnValues:&returnData])
        return false;
    
    //    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    //    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];
    //
    //    NSLog(@"%@", dict);
    
    return true;
}

-(bool)previous:(NSString *)instanceID
{
    NSString *soapAction = @"Previous";
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:instanceID,@"InstanceID", nil];
    NSData *returnData;
    if ([self action:soapAction parameters:params returnValues:&returnData])
        return false;
    
    //    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    //    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];
    //
    //    NSLog(@"%@", dict);
    
    return true;
}

-(NSDictionary *)getMediaInfo:(NSString *)instanceID
{
    NSString *soapAction = @"GetMediaInfo";
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:instanceID,@"InstanceID", nil];
    NSData *returnData;
    [self action:soapAction parameters:params returnValues:&returnData];
    
    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];
    
    return [[dict objectForKey:@"s:Body"] objectForKey:@"u:GetMediaInfoResponse"];
}

-(NSDictionary *)getTransportInfo:(NSString *)instanceID
{
    NSString *soapAction = @"GetTransportInfo";
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:instanceID,@"InstanceID", nil];
    NSData *returnData;
    [self action:soapAction parameters:params returnValues:&returnData];
    
    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];
    
    return [[dict objectForKey:@"s:Body"] objectForKey:@"u:GetTransportInfoResponse"];
}

-(NSDictionary *)getTransportSettings:(NSString *)instanceID
{
    NSString *soapAction = @"GetTransportSettings";
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:instanceID,@"InstanceID", nil];
    NSData *returnData;
    [self action:soapAction parameters:params returnValues:&returnData];
    
    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];
    
    return [[dict objectForKey:@"s:Body"] objectForKey:@"u:GetTransportSettingsResponse"];
}

-(NSDictionary *)getPositionInfo:(NSString *)instanceID
{
    NSString *soapAction = @"GetPositionInfo";
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:instanceID,@"InstanceID", nil];
    NSData *returnData;
    [self action:soapAction parameters:params returnValues:&returnData];
    
    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];
    
    return [[dict objectForKey:@"s:Body"] objectForKey:@"u:GetPositionInfoResponse"];
}

-(NSDictionary *)getDeviceCapabilities:(NSString *)instanceID
{
    NSString *soapAction = @"GetDeviceCapabilities";
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:instanceID,@"InstanceID", nil];
    NSData *returnData;
    [self action:soapAction parameters:params returnValues:&returnData];
    
    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];
    
    return [[dict objectForKey:@"s:Body"] objectForKey:@"u:GetDeviceCapabilitiesResponse"];
}

-(bool)setMediaURI:(NSString *)URI MetaData:(NSString *)meta ID:(NSString *)instanceID
{
    NSString *soapAction = @"SetAVTransportURI";
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:instanceID,@"InstanceID",URI,@"CurrentURI",meta,@"CurrentURIMetaData", nil];
    NSData *returnData;
    if ([self action:soapAction parameters:params returnValues:&returnData])
        return false;
    
    //    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    //    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];
    //
    //    NSLog(@"%@", dict);
    
    return true;
}

-(bool)setNextMediaURI:(NSString *)URI MetaData:(NSString *)meta ID:(NSString *)instanceID
{
    if (!_hasNextURI)
        return false;
    
    NSString *soapAction = @"SetNextAVTransportURI";
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:instanceID,@"InstanceID",URI,@"NextURI",meta,@"NextURIMetaData", nil];
    NSData *returnData;
    if ([self action:soapAction parameters:params returnValues:&returnData]) {
        _hasNextURI = false;
        return false;
    }
    
    //    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    //    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];
    //
    //    NSLog(@"%@", dict);
    
    return true;
}

-(void)checkSCPDURL
{
    // Get AVT.SCPD description
    NSString *SCPD = [NSString stringWithFormat:@"%@%@",[self host], [self SCPDURL]];
    NSURL *SCPDUrl = [NSURL URLWithString:SCPD];
    NSURLRequest* urlRequest=[NSURLRequest requestWithURL:SCPDUrl
                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                          timeoutInterval:1];
    NSHTTPURLResponse *urlResponse;
    NSData *dat = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:nil];
    if ([urlResponse statusCode] != 200)    // Check availability
    {
        DDLogError(@"Error: SCPD description file is unavailable!");
        return;
    }
    
    DDLogVerbose(@"SCPD description: %@", [[NSString alloc] initWithData:dat encoding:NSUTF8StringEncoding]);
    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    NSDictionary *dict = [XMLParser dictionaryWithData:dat];
    
    // Search for neccessary actions
    NSArray *actions = [[dict objectForKey:@"actionList"] objectForKey:@"action"];
    for (NSDictionary *action in actions) {
        if ([[action objectForKey:@"name"] isEqualToString:@"SetNextAVTransportURI"])
            _hasNextURI = true;
    }
}


@end
