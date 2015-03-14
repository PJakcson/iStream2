//
//  SSDPRequest.m
//  UPnPTest
//
//  Created by Florian Bethke on 22.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import "SSDPRequest.h"
#import "GCDAsyncUdpSocket.h"
#import "GlobalLogging.h"

@interface SSDPRequest ()

@property (weak) id<SSDPRequestProtocol> delegate;
@property (nonatomic,strong) GCDAsyncUdpSocket *ssdpSock, *listenSock;
@property (nonatomic,strong) NSTimer *tim;

@end

@implementation SSDPRequest

-(instancetype)initWithDelegate:(id) delegate
{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
        ssdpQueue = dispatch_queue_create("SSDPQueue", NULL);
        
        // Setup listener socket
        _listenSock = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:ssdpQueue];
        
        NSError *socketError = nil;

        if (![_listenSock bindToPort:1900 error:&socketError]) {
            DDLogError(@"Failed binding socket: %@", [socketError localizedDescription]);
        }
        
        if(![_listenSock joinMulticastGroup:@"239.255.255.250" error:&socketError]){
            DDLogError(@"Failed joining multicast group: %@", [socketError localizedDescription]);
        }

        [_listenSock beginReceiving:nil];
    }
    return self;
}

- (void)ssdpMSEARCHRequest
{
    if (_tim)
        [_tim invalidate];
    
    DDLogInfo(@"Searching...");
    NSString *ssdpMSEARCHString = @"M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp:discover\"\r\nMX: 3\r\nST: upnp:rootdevice\r\n\r\n";
    _ssdpSock = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:ssdpQueue];
    
    NSError *socketError = nil;
    
    if (![_ssdpSock bindToPort:0 error:&socketError]) {
        DDLogError(@"Failed binding socket: %@", [socketError localizedDescription]);
    }
    
    if(![_ssdpSock joinMulticastGroup:@"239.255.255.250" error:&socketError]){
        DDLogError(@"Failed joining multicast group: %@", [socketError localizedDescription]);
    }
    
//    if (![_ssdpSock enableBroadcast:TRUE error:&socketError]){
//        DDLogError(@"Failed enabling broadcast: %@", [socketError localizedDescription]);
//    }
    
    [_ssdpSock sendData:[ssdpMSEARCHString dataUsingEncoding:NSUTF8StringEncoding]
                 toHost:@"239.255.255.250"
//                 toHost:@"10.0.1.5"
                   port:1900
            withTimeout:10
                    tag:1];
    
    [_ssdpSock beginReceiving:nil];
    _tim = [NSTimer scheduledTimerWithTimeInterval:11
                                     target:self
                                   selector:@selector(completeSearch:)
                                   userInfo:self
                                    repeats:NO];
}

- (void)completeSearch:(NSTimer *)t
{
    DDLogInfo(@"Timeout, closing ssdp socket...");
    [self.ssdpSock close];
    self.ssdpSock = nil;
    
    // Restart search if no device was found yet
    if ([[_delegate udnList] count] == 0)
        [self ssdpMSEARCHRequest];
    
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *rxData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *headers = [rxData componentsSeparatedByString:@"\n"];
    NSString *location, *UDN, *NTS;
    DDLogVerbose(@"%@", rxData);
    
    // Parse SSDP response
    for (NSString *header in headers)
    {
        NSArray *headerComponents = [header componentsSeparatedByString:@" "];
        if ([[headerComponents firstObject] caseInsensitiveCompare:@"LOCATION:"] == NSOrderedSame)
            location = [[headerComponents objectAtIndex:1] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        else if ([[headerComponents firstObject] caseInsensitiveCompare:@"USN:"] == NSOrderedSame)
            UDN = [[[[headerComponents objectAtIndex:1] componentsSeparatedByString:@"::"] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        else if ([[headerComponents firstObject] caseInsensitiveCompare:@"NTS:"] == NSOrderedSame)
            NTS = [[headerComponents objectAtIndex:1]  stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    }
    
    // Hand response over to delegate
    if (location != nil && UDN != nil)
        [_delegate gotSSDPResponseWithLocation:location UDN:UDN];
    
    if (NTS != nil)
    {
        if ([NTS isEqualToString:@"ssdp:byebye"])
            [_delegate removeDevice:UDN];
    }
}

@end
