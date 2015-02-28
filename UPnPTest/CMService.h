//
//  CMService.h
//  UPnPTest
//
//  Created by Florian Bethke on 22.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import "UPNPService.h"

@interface CMService : UPNPService

-(NSArray *)getProtocolInfo;
-(NSArray *)getConnectionIDs;
-(NSDictionary *)getConnectionInfo:(NSString *)connID;

@end
