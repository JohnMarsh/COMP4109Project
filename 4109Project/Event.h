//
//  Event.h
//  Reactor
//
//  Created by Tony White on 12-03-22.
//  Copyright (c) 2012 Carleton University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "Message.h"



@interface Event : NSObject

@property(strong) NSString *type;
@property(strong) Message  *msg;
@property(strong) MCPeerID *peerID;

-(id) initForType: (NSString*)t withMessage:(Message*)m fromPeer:(MCPeerID*) pID;

@end
     