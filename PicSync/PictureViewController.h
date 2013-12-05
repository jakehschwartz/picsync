//
//  PictureViewController.h
//  PicSync
//
//  Created by Jacob Schwartz on 11/15/13.
//  Copyright (c) 2013 UNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>

@interface PictureViewController : UIViewController //<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    UILabel* picLabel;
    AVCaptureSession *captureSession;
    AVCaptureStillImageOutput *stillImageOutput;
}

-(void) scheduleWithInterval:(NSTimeInterval)time withLabel:(UILabel*) l;

@end
