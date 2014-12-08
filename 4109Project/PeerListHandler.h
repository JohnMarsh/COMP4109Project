//
//  PeerListHandler.h
//  4109Project
//
//  Created by John Marsh on 2014-12-06.
//  Copyright (c) 2014 John Marsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventHandlerProtocol.h"

@interface PeerListHandler : NSObject

-(void) handlePeerList:(Event*) event;

@end
