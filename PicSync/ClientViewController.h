//
//  ClientViewController.h
//  TimeSync
//
//  Created by jacobschwartz on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncUdpSocket.h"
#import "PictureViewController.h"

@interface ClientViewController : PictureViewController <AsyncUdpSocketDelegate,
                                                        UIGestureRecognizerDelegate>
{
    IBOutlet UITextField *one;
    IBOutlet UITextField *two;
    IBOutlet UITextField *three;
    IBOutlet UITextField *four;
    
    IBOutlet UILabel *meanLabel;
    IBOutlet UILabel *stddevLabel;
    IBOutlet UIButton *connectBtn;
    
    IBOutlet UITextView *logField;
    
    double startTime;
    NSMutableArray *diffs;
    AsyncUdpSocket *socket;
}

@property (nonatomic, strong) UITextField *one, *two, *three, *four;
@property (nonatomic, strong) UIButton *connectBtn;
@property (nonatomic, strong) UILabel *meanLabel, *stddevLabel;
@property (nonatomic) double offset;

-(IBAction)connect:(id)sender;
@end
