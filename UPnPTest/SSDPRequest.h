//
//  SSDPRequest.h
//  UPnPTest
//
//  Created by Florian Bethke on 22.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSDPRequest : NSObject {
    dispatch_queue_t ssdpQueue;
}

-(instancetype)initWithDelegate:(id) delegate;
-(void)ssdpMSEARCHRequest;

@end



@protocol SSDPRequestProtocol <NSObject>

-(void)gotSSDPResponseWithLocation:(NSString *)location UDN:(NSString *)UDN;
-(void)removeDevice:(NSString *)UDN;
-(NSArray *)udnList;

@end