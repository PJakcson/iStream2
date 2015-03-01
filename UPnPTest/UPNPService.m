//
//  UPNPService
//  UPnPTest
//
//  Created by Florian Bethke on 22.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import "UPNPService.h"
#import "GCDAsyncSocket.h"
#import "XMLDictionary.h"
#import "GlobalLogging.h"

@interface UPNPService ()

@property (nonatomic,strong) GCDAsyncSocket *socket;
@property (nonatomic,strong) NSMutableArray *sockets;

@end

@implementation UPNPService

-(NSInteger)action:(NSString*)soapAction parameters:(NSDictionary*)parameters returnValues:(NSData**)output
{
    NSUInteger len=0;
    NSInteger ret = 0;

    NSString *hostStr = [NSString stringWithFormat:@"%@%@",_host,_controlURL];
    NSURL *hostURL = [NSURL URLWithString:hostStr];
    if (!hostURL)
    {
        // Control URL could be a full URL
        hostStr = [NSString stringWithFormat:@"%@",_controlURL];
        hostURL = [NSURL URLWithString:hostStr];
        
        // Stop if that doesn't work either
        if(!hostURL)
        {
            DDLogError(@"Error: Control URL is invalid!");
            return 500;
        }
    }
    
    // Generate SOAP message
    NSMutableString *body = [[NSMutableString alloc] init];
    [body appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"];
    [body appendString:@"<s:Envelope s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">"];
    [body appendString:@"<s:Body>"];
    [body appendFormat:@"<u:%@ xmlns:u=\"%@\">", soapAction, _upnpNameSpace];
    for (id key in parameters) {
        [body appendFormat:@"<%@>%@</%@>", key, parameters[key], key];
    }
    [body appendFormat:@"</u:%@>", soapAction];
    [body appendFormat:@"</s:Body></s:Envelope>"];
    len = [body length];
    
    // Generate HTML POST request
    NSMutableURLRequest* urlRequest=[NSMutableURLRequest requestWithURL:hostURL
                                                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:15.0];
    
    [urlRequest setValue:[NSString stringWithFormat:@"\"%@#%@\"", _upnpNameSpace, soapAction] forHTTPHeaderField:@"SOAPACTION"];
    [urlRequest setValue:[NSString stringWithFormat:@"%ld", (unsigned long)len] forHTTPHeaderField:@"CONTENT-LENGTH"];
    [urlRequest setValue:@"text/xml;charset=\"utf-8\"" forHTTPHeaderField:@"CONTENT-TYPE"];
//    [urlRequest setValue:@"Streaming" forHTTPHeaderField:@"transferMode.dlna.org"];
    
    // Send synchronous POST request
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSHTTPURLResponse *urlResponse;
    *output = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:nil];
    
    // Check the Server Return Code
    if([urlResponse statusCode] != 200){
        ret = [urlResponse statusCode];
        NSString *rsp = [[NSString  alloc] initWithData:*output encoding:NSUTF8StringEncoding];
        NSString *caller = NSStringFromClass([self class]);
        DDLogError(@"Error (%@.%@): Got a non 200 response: %ld. Data: %@", caller, soapAction, (long)[urlResponse statusCode], rsp);
    }else{
        ret = 0;
    }
    
    return ret;
}

-(bool)subscribe
{
    // Setup listener
    dispatch_queue_t eventQueue = dispatch_queue_create("EventQueue", NULL);
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:eventQueue];
    NSError *err;
    bool success = [_socket acceptOnInterface:nil port:0 error:&err];
    if (!success)
    {
        DDLogError(@"Error creating event socket!");
        return false;
    }
    
    // Get server address and save it
    NSArray *addresses = [[NSHost currentHost] addresses];
    NSString *addrString;
    for (NSString *address in addresses) {
        if (![address hasPrefix:@"127"] && [[address componentsSeparatedByString:@"."] count] == 4) {
            addrString = address;
            break;
        } else {
            addrString = @"" ;
        }
    }
    if ([addrString isEqualToString:@""]) {
        DDLogError(@"Error: IP address not available!");
        return false;
    }
    NSString *respURL = [NSString stringWithFormat:@"<http://%@:%d>", addrString, [_socket localPort]];
    NSString *hostStr = [NSString stringWithFormat:@"%@%@",_host,_eventURL];
    NSURL *hostURL = [NSURL URLWithString:hostStr];
    if (!hostURL)
    {
        // Control URL could be a full URL
        hostStr = [NSString stringWithFormat:@"%@",_eventURL];
        hostURL = [NSURL URLWithString:hostStr];
        
        // Stop if that doesn't work either
        if(!hostURL)
        {
            DDLogError(@"Error: Event URL is invalid!");
            return 500;
        }
    }
    DDLogInfo(@"Subscribing: %@", hostURL);
    
    // Build subscriotion HTTP request
    NSMutableURLRequest* urlRequest=[NSMutableURLRequest requestWithURL:hostURL
                                                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:30.0];
    [urlRequest setHTTPMethod:@"SUBSCRIBE"];
    [urlRequest setValue:_host forHTTPHeaderField:@"HOST"];
    [urlRequest setValue:respURL forHTTPHeaderField:@"CALLBACK"];
    [urlRequest setValue:@"upnp:event" forHTTPHeaderField:@"NT"];
    [urlRequest setValue:@"SECOND-1800" forHTTPHeaderField:@"TIMEOUT"];

    NSHTTPURLResponse *urlResponse;
    NSData *output = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:nil];
    
    // Check the Server Return Code
    if([urlResponse statusCode] != 200){
        NSString *rsp = [[NSString  alloc] initWithData:output encoding:NSUTF8StringEncoding];
        NSString *caller = NSStringFromClass([self class]);
        DDLogError(@"Error (%@.%@): Got a non 200 response: %ld. Data: %@", caller, @"Subscribe", (long)[urlResponse statusCode], rsp);
        return false;
    }
    DDLogInfo(@"Return: %i", (int)[urlResponse statusCode]);
    return true;
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    if (!_sockets)
        _sockets = [[NSMutableArray alloc] init];
    [_sockets addObject:newSocket];
    [newSocket readDataWithTimeout:-1 tag:HTTP_REQUEST_HEADER];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (tag == HTTP_REQUEST_HEADER)
    {
        // Parse request header
        NSString *rxData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *headers = [rxData componentsSeparatedByString:@"\n"];
        NSString *len, *SID;
        DDLogInfo(@"Received event header: %@", rxData);
        
        for (NSString *header in headers)
        {
            NSArray *headerComponents = [header componentsSeparatedByString:@" "];
            if ([[headerComponents firstObject] caseInsensitiveCompare:@"CONTENT-LENGTH:"] == NSOrderedSame)
                len = [[headerComponents objectAtIndex:1] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            else if ([[headerComponents firstObject] caseInsensitiveCompare:@"SID:"] == NSOrderedSame)
                SID = [[[headerComponents objectAtIndex:1] componentsSeparatedByString:@"::"] objectAtIndex:0];
        }
        
        if (!len || !SID)
        {
            DDLogError(@"Error: Received malformed event header");
            [sock readDataWithTimeout:-1 tag:HTTP_REQUEST_HEADER];
            return;
        }
        
        [sock readDataToLength:[len integerValue] withTimeout:-1 tag:HTTP_REQUEST_BODY];
    }
    else if (tag == HTTP_REQUEST_BODY)
    {
        XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
        NSDictionary *dict = [XMLParser dictionaryWithData:data];
        NSString *lastChange = [[dict objectForKey:@"e:property"] objectForKey:@"LastChange"];
        NSDictionary *lastChangeDict = [XMLParser dictionaryWithString:lastChange];
        
        DDLogInfo(@"Received event body:%@", lastChangeDict);
        
        // TODO: Use updated data
        
        // Start listening again
        [sock readDataWithTimeout:-1 tag:HTTP_REQUEST_HEADER];
    }
}

@end
