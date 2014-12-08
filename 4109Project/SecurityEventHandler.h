//
//  SecurityEventHandler.h
//  4109Project
//
//  Created by John Marsh on 2014-11-18.
//  Copyright (c) 2014 John Marsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventHandlerProtocol.h"

@interface SecurityEventHandler : NSObject<EventHandlerProtocol>

-(void) handleLocalBroadcast:(Event*) event;
-(void) handleGlobalBroadcast:(Event*) event;

@end
