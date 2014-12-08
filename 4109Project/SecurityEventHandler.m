//
//  SecurityEventHandler.m
//  4109Project
//
//  Created by John Marsh on 2014-11-18.
//  Copyright (c) 2014 John Marsh. All rights reserved.
//

#import "SecurityEventHandler.h"
#import "Event.h"
#import "Message.h"

@implementation SecurityEventHandler

-(void) handleEvent:(Event *)event{
    
}

-(void) handleLocalBroadcast:(Event*) event{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedLocalBroadcast" object:[event msg]];
    });
}
-(void) handleGlobalBroadcast:(Event*) event{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedGlobalBroadcast" object:[event msg]];
    });
}


@end
