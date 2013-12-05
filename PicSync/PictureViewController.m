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
    /*AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoOutput setAlwaysDiscardsLateVideoFrames:YES];
    [videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    [videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];*/
    
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
    
    //[captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    [captureSession startRunning];
    
    return YES;
}

-(void) scheduleWithInterval:(NSTimeInterval)time withLabel:(UILabel*) l;
{
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
    NSTimer *timer = [NSTimer timerWithTimeInterval:time
                                             target:self
                                           selector:@selector(takePhoto)
                                           userInfo:nil
                                            repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    NSLog(@"Event scheduled for %lf", [[NSDate date] timeIntervalSince1970] + time);
    picLabel.text = [NSString stringWithFormat:@"Picture in %lf", time];

}


-(void) takePhoto
{
    NSLog(@"Event occurred for %lf", [[NSDate date] timeIntervalSince1970]);
    //[captureSession startRunning];
    AVCaptureConnection *videoConnection = nil;
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
    
    NSLog(@"about to request a capture from: %@ (%@)", stillImageOutput, videoConnection);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
//         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
//         if (exifAttachments)
//             NSLog(@"attachements: %@", exifAttachments);
//         else
//             NSLog(@"no attachments");
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
     }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        picLabel.text = @"Picture Taken";
    }
}
@end
