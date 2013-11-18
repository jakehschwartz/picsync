//
//  PictureViewController.h
//  PicSync
//
//  Created by Jacob Schwartz on 11/15/13.
//  Copyright (c) 2013 UNH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)schedulePhoto:(UIButton *)sender;

@end
