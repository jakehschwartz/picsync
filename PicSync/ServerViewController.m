//
//  ServerViewController.m
//  TimeSync
//
//  Created by jacobschwartz on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerViewController.h"

#include <ifaddrs.h>
#include <arpa/inet.h>

@interface ServerViewController ()

@end

@implementation ServerViewController
@synthesize label;
@synthesize serverSwitch;

#pragma mark - UI Actions
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

#pragma mark - AsyncUdpSocketDelegate
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    
    double time = [[NSDate date] timeIntervalSince1970];
    NSString *string = [NSString stringWithFormat:@"%lf", time];
    NSData *d = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"--------%@:%li(%lf)-----------", host, tag, time);
    [sock sendData:d toHost:host port:port withTimeout:-1 tag:tag];
    [sock receiveWithTimeout:-1 tag:tag + 1];
    //TODO: Add scrolling text field with print outs
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
        label.text = @"Error getting IP. Turn on WiFi and try again later";
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
