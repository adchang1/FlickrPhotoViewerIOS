//
//  Tag+Init.m
//  CoreDataSPOT
//
//  Created by Allen Chang on 2/23/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "Tag+Init.h"

@implementation Tag (Init)

+ (Tag *)tagWithTagName:(NSString *)name
 inManagedObjectContext:(NSManagedObjectContext *)context
{
    Tag *tag = nil;
    
    // This is just like Photo(Flickr)'s method.  Look there for commentary.
    
    if (name.length) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {  
            // handle error
        } else if (![matches count]) {  //does not exist yet, so create a new one
            tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
            tag.name = name;
        } else {    //case where tag already exists. In this case just retrieve that existing tag. 
            tag = [matches lastObject];
        }
    }
    
    return tag;  //this method returns the newly create (or already existing) tag
}

@end
