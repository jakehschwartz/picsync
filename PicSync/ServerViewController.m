//
//  ServerViewController.m
//  TimeSync
//
//  Created by jacobschwartz on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerViewController.h"
#import "PictureViewController.h"

#include <ifaddrs.h>
#include <arpa/inet.h>

@interface ServerViewController ()

@end

@implementation ServerViewController
@synthesize label;
@synthesize serverSwitch;
@synthesize logField;
@synthesize photoBtn;

#pragma mark - UI Actions
-(void) viewDidDisappear:(BOOL)animated
{
    [udpSocket close];
}

-(IBAction)serverSwitched:(id)sender
{
    if (!isServerOn)
    {
        [serverSwitch setTitle:@"Stop" forState:UIControlStateNormal];
        udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
        if (![udpSocket bindToPort:11111 error:nil])
        {
			NSLog(@"Bind error");
            [serverSwitch setTitle:@"Start" forState:UIControlStateNormal];
            isServerOn = !isServerOn;
        }
        [udpSocket receiveWithTimeout:-1 tag:1]; 
    }
    else
    {
        [udpSocket close];
        [serverSwitch setTitle:@"Start" forState:UIControlStateNormal];
    }
    isServerOn = !isServerOn;
}

/**
 * Schedules a photo to be taken to the time selected
 */
-(IBAction)schedulePhoto:(id)sender
{
    // Hide UI components
    photoBtn.hidden = YES;
    photoLabel.hidden = YES;
    
    // Make a action sheet for the picker
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Take photo at:"
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"Enter", nil];
    
    // Add the picker
    picker = [[UIDatePicker alloc] init];
    picker.datePickerMode = UIDatePickerModeDateAndTime;
    [menu addSubview:picker];
    [menu showInView:self.view];
    [menu setBounds:CGRectMake(0,0, 320, 300)];
    
    CGRect pickerRect = picker.bounds;
    pickerRect.origin.y = -75;
    picker.bounds = pickerRect;
}

/**
 * Picker delegate
 */
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // Show UI components
    photoBtn.hidden = NO;
    photoLabel.hidden = NO;
    
    // if not cancel button
    if (buttonIndex != 0) {
        return;
    }
    else {
        // Find the time for the event
        NSTimeInterval timeInt = floor([picker.date timeIntervalSinceReferenceDate] / 60.0) * 60.0;
        NSDate *schedTime = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInt];
        double t = [schedTime timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
        
        // Tell the clients
        NSString *time = [NSString stringWithFormat:@"%lf", [schedTime timeIntervalSince1970]];
        NSData * data = [time dataUsingEncoding:NSUTF8StringEncoding];
        [udpSocket sendData:data toHost:lastHost port:lastPort withTimeout:-1 tag:-1];

        // Schedule event for self
        NSLog(@"Scheduling event for %@", schedTime);
        [self scheduleWithInterval:t withLabel:photoLabel];
    }
}

#pragma mark - AsyncUdpSocketDelegate
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    NSString *cmd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // Request for time
    if ([cmd isEqual:@"_"])
    {
        double time = [[NSDate date] timeIntervalSince1970];
        NSData *d = [[NSString stringWithFormat:@"%lf", time] dataUsingEncoding:NSUTF8StringEncoding];
        [sock sendData:d toHost:host port:port withTimeout:-1 tag:tag];
        [sock receiveWithTimeout:-1 tag:tag + 1];
        logField.text = [logField.text stringByAppendingString:
                         [NSString stringWithFormat:@"Sending %lf to %@ #%li\n", time, host, tag]];
    }
    // Done sending times
    else if ([cmd isEqual:@"!"])
    {
        // Save address of client
        lastHost = host;
        lastPort = port;
        
        // Change buttons
        serverSwitch.enabled = NO;
        photoBtn.enabled = YES;
        photoLabel.text = @" ";

        // Change label
        label.text = [NSString stringWithFormat:@"Connected to client %@", lastHost];
    }

    return TRUE;
}

#pragma mark - Init Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Server";
    
    // Get the IP of the device
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    if ([address isEqualToString:@"error"])
    {
        label.text = @"Error getting IP";
        serverSwitch.hidden = YES;
    }
    else
    {
        label.text = [NSString stringWithFormat:@"Connect to %@", address];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
