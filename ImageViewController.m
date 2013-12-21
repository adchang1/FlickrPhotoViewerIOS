//
//  ImageViewController.m
//  SPoT
//
//  Created by Allen Chang on 2/10/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "ImageViewController.h"
#import "ImageCache.h"
#define IPAD_CACHE_SIZE 10000000
#define IPHONE_CACHE_SIZE 3000000;

@interface ImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;  //inside this UIView controller, we have a SCROLL VIEW and an IMAGE VIEW


@property (strong, nonatomic) UIImageView *imageView;                 //The IMAGE VIEW will be inside the SCROLL VIEW
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong,nonatomic) ImageCache *cache;
@end

@implementation ImageViewController

// resets the image whenever the URL changes

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}


// fetches the data from the URL
// turns it into an image
// adjusts the scroll view's content size to fit the image
// sets the image as the image view's image

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        [self.spinner startAnimating];      // if self.spinner is nil, does nothing
        
        NSURL *imageURL = self.imageURL;    // grab the URL before we start, because we want to make sure that user is still interested after the long load. Need to do a comparison of self.imageURL before and after.
        
        dispatch_queue_t imageFetchQ = dispatch_queue_create("image fetcher", NULL);
        dispatch_async(imageFetchQ, ^{
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // bad
            // UIImage is one of the few UIKit objects which is thread-safe, so we can do this here
            UIImage *image = [self.cache getImage:self.imageURL];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // bad
            // check to make sure we are even still interested in this image (might have touched away)
            if (self.imageURL == imageURL) {
                // dispatch back to main queue to do UIKit work
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        self.scrollView.zoomScale = 1.0;
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                        
                        
                        //custom zoom code
                        float testzoom = self.scrollView.bounds.size.height/image.size.height;  //first assume the height is the limiting dimension - set the zoom to perfectly fit the height
                        if(testzoom*image.size.width >self.scrollView.bounds.size.width){  //as long as the width takes up all the horizontal view space, this zoom is good
                            self.scrollView.zoomScale = testzoom;
                        }
                        else{  //otherwise, use the width to set the zoom
                            self.scrollView.zoomScale = self.scrollView.bounds.size.width/image.size.width;
                        }
                        
                    }
                    [self.spinner stopAnimating];  // spinner should have hidesWhenStopped set
                });
            }
        });
        
        
    }
}

// lazy instantiation

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];  //init gives you a zero size frame so you dont see anything
    return _imageView;
}

// returns the view which will be zoomed when the user pinches
// in this case, it is the image view, obviously
// (there are no other subviews of the scroll view in its content area)

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView   //is this a required method? Or did we make this up as a helper?
{
    return self.imageView;
}

// add the image view to the scroll view's content area
// setup zooming by setting min and max zoom scale
//   and setting self to be the scroll view's delegate
// resets the image in case URL was set before outlets (e.g. scroll view) were set

-(void)refreshCache{
    long cacheSize;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        cacheSize = IPAD_CACHE_SIZE;
    }
    else{
        cacheSize = IPHONE_CACHE_SIZE;
    }
    self.cache = [[ImageCache alloc] initWithCacheLimit:cacheSize];
}

- (void)viewDidLoad  //one of our parent class's methods
{
    [super viewDidLoad];    //we are subclassing UIViewController...so we gotta call this first
    [self.scrollView addSubview:self.imageView];  //do the actual IMPLANTING here!  IMAGEVIEW inside SCROLLVIEW
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    
    [self refreshCache];  //check the sandbox and create a new cache table every time the view loads (in case files were added by a different view controller)
    
}

-(void)viewDidLayoutSubviews{  //here, scrollview size is finally set, so we can use it in zoom calcs
    [self resetImage];
    
}


@end