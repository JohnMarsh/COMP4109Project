//
//  SecurityManager.m
//  4109Project
//
//  Created by John Marsh on 2014-11-05.
//  Copyright (c) 2014 John Marsh. All rights reserved.
//

#import "SecurityManager.h"
#import "Message.h"
#import "MCManager.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#include <stdlib.h>

@implementation SecurityManager

static SecurityManager *sharedSingleton;

+ (SecurityManager *)getInstance{
    @synchronized(self)
    {
        if (!sharedSingleton)
            sharedSingleton = [[SecurityManager alloc] init];
        
        return sharedSingleton;
    }
}

-(SecurityManager*) init{
    self = [super init];
    
    //toy values to reduce overhead while testing
    p = 23;
    g = 5;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLocalBroadcast:)
                                                 name:@"receivedLocalBroadcast"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedGlobalBroadcast:)
                                                 name:@"receivedGlobalBroadcast"
                                               object:nil];
    
    _localPeerValues = [[NSMutableArray alloc] init];
    _localPeerDic = [[NSMutableDictionary alloc] init];
    
    _globalPeerValues = [[NSMutableArray alloc] init];
    _globalPeerDic = [[NSMutableDictionary alloc] init];
    
    
    return self;
}

-(void) newPeerJoinedSession{
    [self sendLocalBroadcast];
}

-(void) newPeerJoinedAtIndex:(int) index{
    NSArray *peers = [[MCManager getInstance] peerList];
    int myIndex = [peers indexOfObject:[[[MCManager getInstance] localPeerID] displayName]];
    int n = [peers count];
    
    if(modulo(myIndex+1,n) == index || modulo(myIndex-1,n) == index){
        
    }
    
}

-(void) peerDisconnected{
    NSArray *peers = [[MCManager getInstance] peerList];
    int myIndex = [peers indexOfObject:[[[MCManager getInstance] localPeerID] displayName]];
    if(myIndex % 2 == 1){
        [self sendLocalBroadcast];
    }
}

//add value to local broadcast values
//if we have two values then we can calculate the value to broadcast globally
-(void) receivedLocalBroadcast: (NSNotification*) notif{
    Message *msg = (Message*) [notif object];
    NSLog(@"received local broadcast with head %@ and body %@", msg.head, msg.body);
    NSNumber *value = [[msg body] objectForKey:@"value"];
    MCPeerID *sender = [[MCPeerID alloc] initWithDisplayName:[[msg body] objectForKey:@"sender"]];
    
    
    //if we already have two values then a new neighbour joined
    if (_localPeerValues.count == 2){
        NSArray *peers = [[MCManager getInstance] peerList];
        int myIndex = [peers indexOfObject:[[[MCManager getInstance] localPeerID] displayName]];
        int n = [peers count];
        MCPeerID *neighbour1 = [[MCManager getInstance] getPeerWithDisplayName: [peers objectAtIndex:modulo(myIndex+1,n)]];
        MCPeerID *neighbour2 = [[MCManager getInstance] getPeerWithDisplayName: [peers objectAtIndex:modulo(myIndex-1,n)]];
        
        NSNumber *val1 = [_localPeerDic objectForKey:neighbour1];
        NSNumber *val2 = [_localPeerDic objectForKey:neighbour2];
        if(val1 == nil){
            _localPeerDic = [[NSMutableDictionary alloc] init];
            [_localPeerDic setObject:val2 forKey:neighbour2];
            _localPeerValues = [[NSMutableArray alloc] init];
            [_localPeerValues addObject:val2];
        }else if (val2 == nil){
            _localPeerDic = [[NSMutableDictionary alloc] init];
            [_localPeerDic setObject:val1 forKey:neighbour1];
            _localPeerValues = [[NSMutableArray alloc] init];
            [_localPeerValues addObject:val1];
        }
    }
    
    [_localPeerDic setObject:value forKey:sender];
    [_localPeerValues addObject:value];
    if (_localPeerValues.count == 2 || [[[[MCManager getInstance] session] connectedPeers] count] == 2) {
        [self sendGlobalBroadcast];
    }
}

//add value to local broadcast values
//if we have all values then we can calculate the key
-(void) receivedGlobalBroadcast: (NSNotification*) notif{
    Message *msg = (Message*) [notif object];
    NSLog(@"received global broadcast with head %@ and body %@", msg.head, msg.body);
    NSNumber *value = [[msg body] objectForKey:@"value"];
    MCPeerID *sender = [[MCPeerID alloc] initWithDisplayName:[[msg body] objectForKey:@"sender"]];
    [_globalPeerDic setObject:value forKey:sender.displayName];
    [_globalPeerValues addObject:value];
    if(_globalPeerValues.count == [[[MCManager getInstance] peerList] count]){
        [self calculateAndSetKey];
    }
}

//once the state of the session changes we will need to send our inital g^x
-(void) sendLocalBroadcast{
    long value = [self generateFirstValue];
    NSLog(@"the first value is %ld", value);
    [[MCManager getInstance] sendValueToNeigbours:value];
}

//once we calculate our second roud value we need to send it to all peers
-(void) sendGlobalBroadcast{
    long value = [self generateSecondValue];
    NSLog(@"the second value is %ld", value);
    [[MCManager getInstance] sendValueToAllPeers:value];
}

-(long) generateFirstValue{
    ki = arc4random_uniform(p);
    return modulo(pow(g, ki),p);
}

-(long) generateSecondValue{
    _localPeerValues = [[NSMutableArray alloc] initWithArray:[_localPeerValues sortedArrayUsingSelector:@selector(compare:)]];
    
    if(_localPeerValues.count >  1){
        NSNumber *numerator = [_localPeerValues objectAtIndex:1];
        NSNumber *denominator = [_localPeerValues objectAtIndex:0];
        
        xi = ((long)pow((numerator.doubleValue/denominator.doubleValue), ki) % p);
        
        return xi;
    } else{
        xi = (modulo(pow(1, ki) , p));
        
        return xi;
    }
}

-(void) calculateAndSetKey{
    NSArray *peers = [[MCManager getInstance] peerList];
    int n = [peers count];
    int myIndex = [peers indexOfObject:[[[MCManager getInstance] localPeerID] displayName]];
    
    
    NSNumber *temp = [_globalPeerDic objectForKey:[peers objectAtIndex:(modulo((myIndex-1),n))]];
    long result = [temp longValue];
    result = modulo(pow(result, ki*n),p);
    
    for (int i = 1; i <=n; i++) {
        NSNumber *temp2 = [_globalPeerDic objectForKey:[peers objectAtIndex:(modulo((myIndex-1),n))]];
        double j = [temp2 doubleValue];
        result = (result *  modulo(pow(j, n-i),p));
    }
    key = (int)result % p;
    NSLog(@"the key is %ld", key);
}

//C99 defines a%b to be negative when a is negative
// here is a workaround that should behave like proper modular arithmetic
long modulo(long a, long b){
    return (a >= 0) ? (a % b) : ((a % b) + b);
}



@end
