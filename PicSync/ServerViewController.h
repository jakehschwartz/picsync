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
                                                    UIActionSheetDelegate,
                                                    UINavigationControllerDelegate>
{
    IBOutlet UILabel *label;
    IBOutlet UIButton *serverSwitch;
    IBOutlet UITextView *logField;
    IBOutlet UIButton *photoBtn;
    IBOutlet UILabel *photoLabel;
    UIDatePicker *picker;

    
    AsyncUdpSocket *udpSocket;
    bool isServerOn;
    NSString *lastHost;
    UInt16 lastPort;
}
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *serverSwitch;
@property (nonatomic, strong) UITextView *logField;
@property (nonatomic, strong) UIButton *photoBtn;

-(IBAction)serverSwitched:(id)sender;
-(IBAction)schedulePhoto:(id)sender;

@end
