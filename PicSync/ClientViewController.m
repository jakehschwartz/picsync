//
//  ClientViewController.m
//  TimeSync
//
//  Created by jacobschwartz on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ClientViewController.h"
#import "PictureViewController.h"

#define kPort 11111

@implementation ClientViewController
@synthesize one, two, three, four, connectBtn, meanLabel, stddevLabel;

#pragma mark - UI Actions
/**
 * Connect to the server
 */
-(IBAction)connect:(id)sender
{
    // Make sure an address has been entered
    if (one.text.length == 0 || two.text.length == 0 || 
        three.text.length == 0 || four.text.length == 0)
    {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Fill in all the fields"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
            
        [myAlertView show];
        return;
    }
    
    // Set up for connection
    connectBtn.enabled = NO;
    diffs = [[NSMutableArray alloc] init];
    
    // Send packet
    socket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    NSString *address = [NSString stringWithFormat:@"%@.%@.%@.%@", one.text,
                         two.text, three.text, four.text];
    NSString * string = @"_";
    UInt16 port = kPort;
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    startTime = [[NSDate date] timeIntervalSince1970];
    [socket sendData:data toHost:address port:port withTimeout:-1 tag:0];
    [socket receiveWithTimeout:-1 tag:0];
}

#pragma mark - AsyncUdpSocketDelegate
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    // Get the time sent back
    NSString *time = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    double serverTime = [time doubleValue];

    // If the tag is -1, schedule a photo
    if (tag == -1)
    {
        NSLog(@"Schedule event for %@", [NSDate dateWithTimeIntervalSince1970:serverTime + self.offset]);
        [self scheduleWithInterval:serverTime - [[NSDate date] timeIntervalSince1970] + self.offset
                         withLabel:connectBtn.titleLabel];
        [socket receiveWithTimeout:-1 tag:-1];
    }
    // otherwise, save the difference
    else
    {
        // Do the calculations
        double time = [[NSDate date] timeIntervalSince1970];
        double sendTime = (time - startTime) / 2;
        double difference = time - serverTime - sendTime;
        
        // Log the difference
        if (serverTime != 0)
        {
            logField.text = [logField.text stringByAppendingString:
                             [NSString stringWithFormat:@"Difference #%li: %lf - %lf = %lf\n",
                              tag, serverTime, startTime, difference]];
            [diffs addObject:[NSNumber numberWithDouble:difference]];
        }
        else
        {
            logField.text = [logField.text stringByAppendingString:
                             [NSString stringWithFormat:@"Failed to get reading #%li\n",tag]];
        }
        
        // Send next request or wait for picture request
        if (++tag < 10)
        {
            NSData *data = [NSData dataWithBytes:"_" length:1];
            startTime = [[NSDate date] timeIntervalSince1970];
            [socket sendData:data toHost:host port:port withTimeout:-1 tag:tag];
            [socket receiveWithTimeout:-1 tag:tag];
        }
        else
        {
            [self calcMeanStdDev];
            
            NSData *data = [NSData dataWithBytes:"!" length:1];
            [socket sendData:data toHost:host port:port withTimeout:-1 tag:tag];
            [socket receiveWithTimeout:-1 tag:-1];
        }
    }

    
    return TRUE;
}

#pragma mark - View LifeCycle
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
    self.title = @"Client";

    UITapGestureRecognizer *tap = 
        [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                action:@selector(dismissKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    // Do any additional setup after loading the view from its nib.
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ((touch.view == connectBtn)) 
    {
        return NO;
    }
    return YES;
}

-(void)dismissKeyboard
{
    UITextField *activeTextField = nil;
    if ([one isEditing]) 
    {
        activeTextField = one;
    }
    else if ([two isEditing]) 
    {
        activeTextField = two;
    }
    else if ([three isEditing])
    {
        activeTextField = three;
    }
    else if ([four isEditing]) 
    { 
        activeTextField = four;
    }
    
    if (activeTextField) 
    {
        [activeTextField resignFirstResponder];
    }
}

#pragma mark calculations

-(void)calcMeanStdDev
{
    double mean = 0;
    for (NSNumber *n in diffs)
    {
        mean += [n doubleValue];
    }
    mean /= diffs.count;
    self.meanLabel.text = [NSString stringWithFormat:@"%0.5lf", mean];
    
    NSMutableArray *devs = [NSMutableArray array];
    for (NSNumber *n in diffs)
    {
        double dev = mean - [n doubleValue];
        [devs addObject:[NSNumber numberWithDouble:dev * dev]];
    }
    
    double stddev = 0;
    for (NSNumber *n in devs)
    {
        stddev += [n doubleValue];
    }
    stddev /= (devs.count - 1);
    self.stddevLabel.text = [NSString stringWithFormat:@"%0.5lf", sqrt(stddev)];
    
    self.offset = mean;
}

@end
