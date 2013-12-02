//
//  PictureViewController.m
//  PicSync
//
//  Created by Jacob Schwartz on 11/15/13.
//  Copyright (c) 2013 UNH. All rights reserved.
//

#import "PictureViewController.h"

@interface PictureViewController ()

@end

@implementation PictureViewController

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
    done = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidLoad];
    if (done)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
    else
    {
        picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = NO;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:self.time/1000
                                                 target:self
                                               selector:@selector(takePhoto)
                                               userInfo:nil
                                                repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        NSLog(@"Event scheduled");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)takePhoto {
    [picker takePicture];
    
}

#pragma mark UIPickerViewDelegate

- (void)imagePickerController:(UIImagePickerController *)p didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSLog(@"Picture taken");
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(chosenImage, nil, nil, nil);

    done = YES;
    [p dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)p {
    
    done = YES;
    [p dismissViewControllerAnimated:YES completion:nil];
}

@end
