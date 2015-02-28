//
//  UPNPService
//  UPnPTest
//
//  Created by Florian Bethke on 22.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import "UPNPService.h"
#import "DDLog.h"
#import "GlobalLogging.h"

@implementation UPNPService

-(NSInteger)action:(NSString*)soapAction parameters:(NSDictionary*)parameters returnValues:(NSData**)output
{
    NSUInteger len=0;
    NSInteger ret = 0;
    NSString *hostStr = [NSString stringWithFormat:@"%@%@",_host,_controlURL];
    NSURL *hostURL = [NSURL URLWithString:hostStr];
    
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

@end
