//
//  ServerViewController.h
//  TimeSync
//
//  Created by jacobschwartz on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncUdpSocket.h"
#import "PictureViewController.h"

@interface ServerViewController : PictureViewController <AsyncUdpSocketDelegate,
                                                    UIImagePickerControllerDelegate,
                                                    UINavigationControllerDelegate>
{
    IBOutlet UILabel *label;
    IBOutlet UIButton *serverSwitch;
    IBOutlet UITextView *logField;
    
    AsyncUdpSocket *udpSocket;
    bool isServerOn;
}
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *serverSwitch;
@property (nonatomic, strong) UITextView *logField;

-(IBAction)serverSwitched:(id)sender;

@end
