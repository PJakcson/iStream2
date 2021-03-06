//
//  UPNPService
//  UPnPTest
//
//  Created by Florian Bethke on 22.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HTTP_REQUEST_HEADER                10
#define HTTP_REQUEST_BODY                  11

@interface UPNPService : NSObject

@property (nonatomic,strong) NSString *upnpNameSpace;
@property (nonatomic,strong) NSString *controlURL;
@property (nonatomic,strong) NSString *eventURL;
@property (nonatomic,strong) NSString *SCPDURL;
@property (nonatomic,strong) NSString *host;

-(NSInteger)action:(NSString*)soapAction parameters:(NSDictionary*)parameters returnValues:(NSData**)output;
-(bool)subscribe;

@end
