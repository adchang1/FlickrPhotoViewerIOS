//
//  Photo+Init.h
//  CoreDataSPOT
//
//  Created by Allen Chang on 2/23/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "Photo.h"

@interface Photo (Init)

//Acts as an initializer and getter.  Returns the photo object with the specified name.  If it doesn't exist yet, this method will create it and then return it.
// Creates a Photo in the database for the given Flickr photo dict (if necessary). 

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
