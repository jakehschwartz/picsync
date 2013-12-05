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

@interface ClientViewController ()
-(void)dismissKeyboard;
-(void)calcMeanStdDev;
@end

@implementation ClientViewController
@synthesize one, two, three, four, connectBtn, meanLabel, stddevLabel;

#pragma mark - UI Actions
-(IBAction)connect:(id)sender
{
    if (one.text.length == 0 || two.text.length == 0 || 
        three.text.length == 0 || four.text.length == 0)
    {
        NSLog(@"Nice try");
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Fill in all the fields"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
            
        [myAlertView show];
        return;
    }
    
    connectBtn.enabled = NO;
    if (diffs == nil)
    {
        diffs = [[NSMutableArray alloc] init];
    }
    else 
    {
        [diffs removeAllObjects];
    }
    
    NSString *address = [NSString stringWithFormat:@"%@.%@.%@.%@", one.text,
                         two.text, three.text, four.text];
    
    socket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    NSString * string = @"_";
    UInt16 port = kPort;
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    startTime = [[NSDate date] timeIntervalSince1970];
    [socket sendData:data toHost:address port:port withTimeout:-1 tag:0];
    [socket receiveWithTimeout:-1 tag:0];
}

-(IBAction)schedulePhoto:(id)sender
{
    UIAlertView * alert = nil;
    /*if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:@"Device has no camera"
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles: nil];
    }
    else{*/
        // Time picker modal
        alert = [[UIAlertView alloc] initWithTitle:@"Schedule Photo"
                                           message:@"Take photo in how many seconds?"
                                          delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 otherButtonTitles:@"Enter", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //}
    
    [alert show];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *textField = [alertView textFieldAtIndex:0];
    NSString* detailString = textField.text;
    
    if ([textField.text length] <= 0 || buttonIndex == 0) {
        return;
    }
    else {
        double t = [detailString doubleValue];
        
        // Send data
        NSString *address = [NSString stringWithFormat:@"%@.%@.%@.%@", one.text,
                             two.text, three.text, four.text];
        UInt16 port = kPort;
        NSString *time = [NSString stringWithFormat:@"%lf", t];
        NSData * data = [time dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"Sending camera request to %@:%d for %lf seconds", address, port, t);
        [socket sendData:data toHost:address port:port withTimeout:-1 tag:0];
        
        //[self scheduleWithInterval:t + self.offset withLabel:photoBtn.titleLabel];
        [self scheduleWithInterval:t withLabel:photoBtn.titleLabel];
    }
}

#pragma mark - AsyncUdpSocketDelegate
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    NSLog(@"--------%@:%li-----------", host, tag);
    NSString* newStr = [NSString stringWithUTF8String:[data bytes]];
    double serverTime = [newStr doubleValue];
    double time = [[NSDate date] timeIntervalSince1970];
    double sendTime = (time - startTime) / 2;
    double difference = serverTime - startTime - sendTime;
    
    //double difference = sendTime;
    
    if (serverTime != 0)
    {
        NSLog(@"Difference #%li: %lf - %lf = %lf", tag, serverTime, startTime, difference);
        logField.text = [logField.text stringByAppendingString:
                         [NSString stringWithFormat:@"Difference #%li: %lf - %lf = %lf\n",
                          tag, serverTime, startTime, difference]];
        [diffs addObject:[NSNumber numberWithDouble:difference]];
    }
    else
    {
        NSLog(@"Failed to get reading #%li", tag);
        logField.text = [logField.text stringByAppendingString:
                         [NSString stringWithFormat:@"Failed to get reading #%li\n",tag]];
    }
    
    if (++tag < 10)
    {
        NSData *data = [NSData dataWithBytes:"_" length:1];
        startTime = [[NSDate date] timeIntervalSince1970];
        [sock sendData:data toHost:host port:port withTimeout:-1 tag:tag];
        [socket receiveWithTimeout:-1 tag:tag];
    }
    else
    {
        [self calcMeanStdDev];
        
        NSData *data = [NSData dataWithBytes:"!" length:1];
        [sock sendData:data toHost:host port:port withTimeout:-1 tag:tag];
        
        connectBtn.enabled = YES;
        photoBtn.enabled = YES;
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
    NSLog(@"Calced: %lf : %lf", mean, stddev);
    
    self.offset = mean;
}

@end
