//
//  PictureViewController.h
//  PicSync
//
//  Created by Jacob Schwartz on 11/15/13.
//  Copyright (c) 2013 UNH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImagePickerController *picker;
    bool done;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) double time;

@end
