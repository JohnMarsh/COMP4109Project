//
//  ViewController.m
//  4109Project
//
//  Created by John Marsh on 2014-10-22.
//  Copyright (c) 2014 John Marsh. All rights reserved.
//

#import "BrowserViewController.h"

@interface BrowserViewController ()

@end


@implementation BrowserViewController

@synthesize tableView;
@synthesize visibleSwitch;
@synthesize navigationBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    _mcManager = [MCManager getInstance];
    [_mcManager setDelegate:self];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[_mcManager advertisingPeers] count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    
     cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:@"SessionCell"];
            
    cell.textLabel.text = [[[_mcManager advertisingPeerInfo] objectForKey:[[_mcManager advertisingPeers] objectAtIndex:indexPath.row]] objectForKey:@"peerName"];
   
    return cell;
}

-(void) refreshPeerList{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_mcManager invitePeerAtIndex:indexPath.row];
}

-(void) showInviteAlert:(UIAlertController*) alert{
    [self presentViewController:alert animated:YES completion:nil];
}


@end
