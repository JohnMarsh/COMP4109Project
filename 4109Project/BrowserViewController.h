//
//  ViewController.h
//  4109Project
//
//  Created by John Marsh on 2014-10-22.
//  Copyright (c) 2014 John Marsh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "MCManager.h"

@interface BrowserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MCManagerDelegate>{
    MCManager *_mcManager;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISwitch *visibleSwitch;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

