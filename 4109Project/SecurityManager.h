//
//  SecurityManager.h
//  4109Project
//
//  Created by John Marsh on 2014-11-05.
//  Copyright (c) 2014 John Marsh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityManager : NSObject{
    long p;
    long g;
    long ki;
    long xi;
    long key;
    NSMutableArray *_localPeerValues;
    NSMutableArray *_globalPeerValues;
    NSMutableDictionary *_localPeerDic;
    NSMutableDictionary *_globalPeerDic;
}

+(SecurityManager*) getInstance;

-(void) newPeerJoinedAtIndex:(int) index;
-(void) newPeerJoinedSession;
-(void) peerDisconnected;

@end
