//
//  PictureViewController.m
//  PicSync
//
//  Created by Jacob Schwartz on 11/15/13.
//  Copyright (c) 2013 UNH. All rights reserved.
//

#import "PictureViewController.h"
#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"

@implementation PictureViewController

/**
 * Initialize the camera and start the av session
 */
- (bool)initializeCamera
{
    // Grab the back-facing camera
    AVCaptureDevice *backFacingCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == AVCaptureDevicePositionBack)
        {
            backFacingCamera = device;
        }
    }
    
    // Create the capture session
    captureSession = [[AVCaptureSession alloc] init];
 
    // Add the video input
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:backFacingCamera error:&error];
    if (error != nil)
    {
        return NO;
    }
    if ([captureSession canAddInput:videoInput])
    {
        [captureSession addInput:videoInput];
    }

    // Add the video frame output
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    if ([captureSession canAddOutput:stillImageOutput])
    {
        [captureSession addOutput:stillImageOutput];
    }
    else
    {
        NSLog(@"Couldn't add video output");
        return NO;
    }
    
    [captureSession startRunning];
    
    // Find the video output
    for (AVCaptureConnection *connection in stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    
    
    return YES;
}

/**
 * Schedules a photo to be taken in time seconds and will chage the label l
 */
-(void) scheduleWithInterval:(NSTimeInterval)time withLabel:(UILabel*) l;
{
    // If no camera, print error
    if (![self initializeCamera])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"No camera"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    picLabel = l;
    
    // Schedule the event
    NSTimer *timer = [NSTimer timerWithTimeInterval:time
                                             target:self
                                           selector:@selector(takePhoto)
                                           userInfo:nil
                                            repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    NSLog(@"Event scheduled for %lf", [[NSDate date] timeIntervalSince1970] + time);
    picLabel.text = [NSString stringWithFormat:@"Picture in %lf", time];

}

/**
 * Take the photo and save it to the camera roll
 */
-(void) takePhoto
{
    NSLog(@"Event occurred for %lf", [[NSDate date] timeIntervalSince1970]);
    
    // Take the photo
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         // Save to camera roll
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
     }];
    picLabel.text = @"Picture Taken";
}

/**
 * Camera roll save delegate
 */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // Print if ther was an error
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        picLabel.text = @"Saved to camera roll";
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
