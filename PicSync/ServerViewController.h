//
//  ServerViewController.h
//  TimeSync
//
//  Created by jacobschwartz on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncUdpSocket.h"

@interface ServerViewController : UIViewController <AsyncUdpSocketDelegate>
{
    IBOutlet UILabel *label;
    IBOutlet UIButton *serverSwitch;
    
    AsyncUdpSocket *udpSocket;
    bool isServerOn;
}
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *serverSwitch;

-(IBAction)serverSwitched:(id)sender;

@end
