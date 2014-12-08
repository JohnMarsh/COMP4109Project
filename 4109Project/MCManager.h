//
//  MCManager.h
//  4109Project
//
//  Created by John Marsh on 2014-10-22.
//  Copyright (c) 2014 John Marsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "ServerReactor.h"

@protocol MCManagerDelegate <NSObject>

-(void) refreshPeerList;
-(void) showInviteAlert:(UIAlertController*) displayName;

@end

@interface MCManager : NSObject<MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>{
   
    MCPeerID *_localPeerID;
    MCNearbyServiceAdvertiser *_advertiser;
    MCSession *_session;
    MCNearbyServiceBrowser *_browser;
    ServerReactor *_reactor;
    NSMutableArray *_advertisingPeers;
    NSMutableDictionary *_advertisingPeerInfo;
    NSMutableDictionary *_myAdvertisingInfo;
    NSMutableArray *_peerList;
    id<MCManagerDelegate> _delegate;
    BOOL isMaster;
}

@property (nonatomic, strong) MCPeerID *localPeerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong) ServerReactor *reactor;
@property (nonatomic, strong) NSMutableArray *advertisingPeers;
@property (nonatomic, strong) NSMutableArray *peerList;
@property (nonatomic, strong) NSMutableDictionary *advertisingPeerInfo;
@property (nonatomic, strong) NSMutableDictionary *myAdvertisingInfo;
@property (nonatomic, strong) id<MCManagerDelegate> delegate;


+(MCManager*) getInstance;
-(void) invitePeerAtIndex:(int) index;
-(void) sendTextToPeers:(NSString*) text;
-(void) sendValueToAllPeers:(long)value;
-(void) sendValueToNeigbours:(long)value;

-(MCPeerID*) getPeerWithDisplayName:(NSString*) displayName;

@end
