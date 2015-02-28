//
//  UPNPService
//  UPnPTest
//
//  Created by Florian Bethke on 22.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPNPService : NSObject

@property (nonatomic,strong) NSString *upnpNameSpace;
@property (nonatomic,strong) NSString *controlURL;
@property (nonatomic,strong) NSString *eventURL;
@property (nonatomic,strong) NSString *host;

-(NSInteger)action:(NSString*)soapAction parameters:(NSDictionary*)parameters returnValues:(NSData**)output;


@end
