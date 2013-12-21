//
//  ImageViewController.h
//  SPoT
//
//  Created by Allen Chang on 2/10/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

// the Model for this VC
// simply the URL of a UIImage-compatible image (jpg, png, etc.)
@property (nonatomic, strong) NSURL *imageURL;

@end