//
//  ServerTextHandler.m
//  COMP2601iPhoneAssignment3
//
//  Created by John Marsh on 13-04-03.
//  Copyright (c) 2013 John Marsh. All rights reserved.
//

#import "ServerTextHandler.h"
#import "Event.h"
#import "Message.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@implementation ServerTextHandler
-(void) handleEvent:(Event *)event{
    Message *msg = [event msg];
    NSString *sender = [[msg body] objectForKey:@"sender"];
    NSString *text = [[msg body] objectForKey:@"text"];
    NSLog(@"Received message from %@ with contents: %@", sender, text);
}
@end
