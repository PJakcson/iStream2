//
//  CMService.m
//  UPnPTest
//
//  Created by Florian Bethke on 22.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import "CMService.h"
#import "XMLDictionary.h"
#import "GlobalLogging.h"

@implementation CMService

-(NSArray *)getProtocolInfo
{
    NSString *soapAction = @"GetProtocolInfo";
    NSData *returnData;
    [self action:soapAction parameters:nil returnValues:&returnData];
    
    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];

    NSString *protocolInfo = [[[dict objectForKey:@"s:Body"] objectForKey:@"u:GetProtocolInfoResponse"] objectForKey:@"Sink"];
    NSArray *protocols = [protocolInfo componentsSeparatedByString:@","];
    
    return protocols;
}

-(NSArray *)getConnectionIDs
{
    NSString *soapAction = @"GetCurrentConnectionIDs";
    NSData *returnData;
    [self action:soapAction parameters:nil returnValues:&returnData];
    
    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];
    
    NSString *connIDStr = [[[dict objectForKey:@"s:Body"] objectForKey:@"u:GetCurrentConnectionIDsResponse"] objectForKey:@"ConnectionIDs"];
    NSArray *connIDs = [connIDStr componentsSeparatedByString:@","];
    
    DDLogInfo(@"%@", connIDs);
    
//    for (NSString *connID in connIDs)
//        NSLog(@"%@", [self getConnectionInfo:connID]);
    
    return connIDs;
}

-(NSDictionary *)getConnectionInfo:(NSString *)connID
{
    NSString *soapAction = @"GetCurrentConnectionInfo";
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:connID,@"ConnectionID", nil];
    NSData *returnData;
    [self action:soapAction parameters:params returnValues:&returnData];
    
    XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
    NSDictionary *dict = [XMLParser dictionaryWithData:returnData];
    
    return [[dict objectForKey:@"s:Body"] objectForKey:@"u:GetCurrentConnectionInfoResponse"];
}

@end
