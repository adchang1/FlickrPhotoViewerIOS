//
//  Photo+Init.m
//  CoreDataSPOT
//
//  Created by Allen Chang on 2/23/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "Photo+Init.h"
#import "FlickrFetcher.h"
#import "Tag+Init.h"

@implementation Photo (Init)


+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    // Build a fetch request to see if we can find this Flickr photo in the database.
    // The "unique" attribute in Photo is Flickr's "id" which is guaranteed by Flickr to be unique.
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"ident = %@", [photoDictionary[FLICKR_PHOTO_ID] description]];  //filters based on equality to the specified unique id
    
    // Execute the fetch
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // Check what happened in the fetch
    
    if (!matches || ([matches count] > 1)) {  // nil means fetch failed; more than one impossible (unique!)
        // handle error
    } else if (![matches count]) { // none found, so let's create a Photo for that Flickr photo
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.ident = [photoDictionary[FLICKR_PHOTO_ID] description];
        photo.title = [photoDictionary[FLICKR_PHOTO_TITLE] description];
        photo.about = [photoDictionary[FLICKR_PHOTO_DESCRIPTION][@"_content"] description];
        photo.url = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.urlipad = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatOriginal] absoluteString];
        photo.thumburl = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        
        dispatch_queue_t imageFetchQ = dispatch_queue_create("image fetcher", NULL);
        dispatch_async(imageFetchQ, ^{
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // bad
            // UIImage is one of the few UIKit objects which is thread-safe, so we can do this here
            NSURL *url =[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatSquare];
            photo.thumbdata = [[NSData alloc] initWithContentsOfURL: url];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // bad
          
        });

        photo.datemodified = nil;  //if this is a newly created object, we obviously have never looked at it before - should have nil date
        
        NSString *tagString = [photoDictionary[FLICKR_TAGS] description];
        NSArray *tagArray = [self createTagArray:tagString];
        NSMutableSet *tagSet = [[NSMutableSet alloc]init];  //create a mutable set that will eventually become the tag set
        for(NSString *tagName in tagArray){
            Tag *tag = [Tag tagWithTagName: tagName inManagedObjectContext:context];
            [tagSet addObject:tag];
        }
        photo.tag = tagSet;
      
    } else { // found the Photo, just return it from the list of matches (which there will only be one of)
        photo = [matches lastObject];
    }
    
    return photo;
}

+ (NSArray *) createTagArray:(NSString *)tagString{
    return  [tagString componentsSeparatedByString:@" "];
}

@end
