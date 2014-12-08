//
//  PeerListHandler.m
//  4109Project
//
//  Created by John Marsh on 2014-12-06.
//  Copyright (c) 2014 John Marsh. All rights reserved.
//

#import "PeerListHandler.h"
#import "Event.h"

@implementation PeerListHandler

-(void) handlePeerList:(Event *)event{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedPeerList" object:[event msg]];
    });
}



@end
