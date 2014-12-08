//
//  MCManager.m
//  4109Project
//
//  Created by John Marsh on 2014-10-22.
//  Copyright (c) 2014 John Marsh. All rights reserved.
//

#import "MCManager.h"
#import "Event.h"
#import "SecurityManager.h"

static NSString * const XXServiceType = @"xx4109-Service";

@implementation MCManager

@synthesize advertiser = _advertiser;
@synthesize session = _session;
@synthesize browser = _browser;
@synthesize localPeerID = _localPeerID;
@synthesize reactor = _reactor;
@synthesize advertisingPeers = _advertisingPeers;
@synthesize delegate = _delegate;
@synthesize peerList = _peerList;

static MCManager *sharedSingleton;

+ (MCManager *)getInstance{
    @synchronized(self)
    {
        if (!sharedSingleton)
            sharedSingleton = [[MCManager alloc] init];
        
        return sharedSingleton;
    }
}


-(MCManager*) init{
    self = [super init];
    
    isMaster = YES;

    _localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    
    _session = [[MCSession alloc] initWithPeer:_localPeerID];
    [_session setDelegate:self];
    
    _advertisingPeers = [[NSMutableArray alloc] init];
    _advertisingPeerInfo = [[NSMutableDictionary alloc] init];
    
    _reactor = [[ServerReactor alloc] initWithProperties];
    
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_localPeerID discoveryInfo:@{@"peerName" : [[UIDevice currentDevice] name]} serviceType:XXServiceType];
    [_advertiser setDelegate:self];
    
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_localPeerID serviceType:XXServiceType];
    [_browser setDelegate:self];
    
  
    
    [_advertiser startAdvertisingPeer];
    [_browser startBrowsingForPeers];
    
    _peerList = [[NSMutableArray alloc] initWithObjects:_localPeerID.displayName, nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPeerList:)
                                                 name:@"receivedPeerList"
                                               object:nil];
    
    return self;
}

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    switch (state) {
        case MCSessionStateConnected:{
            NSLog(@"Peer %@ has joined the session", peerID);
            [[SecurityManager getInstance] newPeerJoinedSession];
        }
            break;
        case MCSessionStateConnecting:
            NSLog(@"Peer %@ is joining the session", peerID);
            break;
        default : ;
            
    }
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    //dispatch the message to the reactor
    Message *msg = [[Message alloc] initFromJSON:data];
    NSLog(@"received message with head %@ and body %@", msg.head, msg.body);
    Event *e = [[Event alloc] initForType:[msg.head objectForKey:@"type"] withMessage:msg fromPeer:peerID];
    [_reactor dispatch:e];
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    //for pictures and stuff ignore for this app
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    //for pictures and stuff ignore for this app
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    //for pictures and stuff ignore for this app
}


// Found a nearby advertising peer
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info{
    [_advertisingPeers addObject:peerID];
    [_advertisingPeerInfo setObject:info forKey:peerID];
    [_delegate refreshPeerList];
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
    [_advertisingPeers removeObject:peerID];
    [_advertisingPeerInfo removeObjectForKey:peerID];
    [_delegate refreshPeerList];
}

-(void) session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler{
    certificateHandler(YES);
    [_peerList addObject:peerID.displayName];
    if(isMaster){
        [self broadcastPeerList];
    }
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Recieved Invitation"
                                  message:[NSString stringWithFormat:@"Would you like to join %@'s session?", [peerID displayName]]
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yes = [UIAlertAction
                          actionWithTitle:@"Yes"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                               invitationHandler(YES, _session);
                              [_advertiser stopAdvertisingPeer];
                              isMaster = NO;
                              
                          }];
    
    UIAlertAction *no = [UIAlertAction
                          actionWithTitle:@"No"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              invitationHandler(NO, nil);
                          }];
    
    
    [alert addAction:yes];
    [alert addAction:no];
    
    [_delegate showInviteAlert:alert];
}

-(void) invitePeerAtIndex:(int) index{
    [_browser invitePeer:[_advertisingPeers objectAtIndex:index] toSession:_session withContext:nil timeout:0];
}

-(void) sendTextToPeers:(NSString *)text{
    Message *msg = [[Message alloc] initWithType:@"TEXT"];
    [[msg body] setObject:[_localPeerID displayName] forKey:@"sender"];
    [[msg body] setObject:text forKey:@"text"];
    NSError *error = nil;
    [_session sendData:[msg toJSON] toPeers:[_session connectedPeers] withMode:MCSessionSendDataReliable error:&error];
    NSLog(@"[Error] %@", error);
}

-(void) sendValueToNeigbours:(long)value{
    Message *msg = [[Message alloc] initWithType:@"localBroadcast"];
    [[msg body] setObject:[_localPeerID displayName]  forKey:@"sender"];
    [[msg body] setObject:[NSNumber numberWithLong:value] forKey:@"value"];
    NSError *error = nil;
      
    long index =  [_peerList indexOfObject:_localPeerID.displayName];
    
    NSString *neighbour1 = [_peerList objectAtIndex:(index + 1) % [_peerList count]];
    NSString *neighbour2 = [_peerList objectAtIndex:(index - 1) % [_peerList count]];
    
    NSArray *neighbours = [[NSArray alloc] initWithObjects:
    [self getPeerWithDisplayName:neighbour1],
    [self getPeerWithDisplayName:neighbour2], nil];
    
    
    [_session sendData:[msg toJSON] toPeers:neighbours withMode:MCSessionSendDataReliable error:&error];
    NSLog(@"[Error] %@", error);
}

-(void) sendValueToAllPeers:(long)value{
    Message *msg = [[Message alloc] initWithType:@"globalBroadcast"];
    [[msg body] setObject:[_localPeerID displayName] forKey:@"sender"];
    [[msg body] setObject:[NSNumber numberWithLong:value] forKey:@"value"];
    NSError *error = nil;
    
    [_session sendData:[msg toJSON] toPeers:[_session connectedPeers] withMode:MCSessionSendDataReliable error:&error];
    NSLog(@"[Error] %@", error);
}

-(void) broadcastPeerList{
    Message *msg = [[Message alloc] initWithType:@"peerList"];
    [[msg body] setObject:[_localPeerID displayName] forKey:@"sender"];
    [[msg body] setObject:_peerList forKey:@"peerList"];
    NSError *error = nil;
    
    [_session sendData:[msg toJSON] toPeers:[_session connectedPeers] withMode:MCSessionSendDataReliable error:&error];
    NSLog(@"[Error] %@", error);

}

-(void) receivedPeerList:(NSNotification*) notif{
    Message *msg = (Message*) [notif object];
    NSLog(@"received global broadcast with head %@ and body %@", msg.head, msg.body);
    NSArray *array = [[msg body] objectForKey:@"peerList"];
    _peerList = [[NSMutableArray alloc] initWithArray:array];
}

-(MCPeerID*) getPeerWithDisplayName:(NSString*) displayName{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayName == %@", displayName];
    NSArray *filteredArray = [[_session connectedPeers] filteredArrayUsingPredicate:predicate];
    MCPeerID *firstFoundObject = nil;
    firstFoundObject =  filteredArray.count > 0 ? filteredArray.firstObject : nil;
    return firstFoundObject;
}


@end


