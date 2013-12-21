//
//  Tag+Init.h
//  CoreDataSPOT
//
//  Created by Allen Chang on 2/23/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "Tag.h"

@interface Tag (Init)

//Acts as an initializer and getter.  Returns the tag object with the specified name.  If it doesn't exist yet, this method will create it and then return it.

+ (Tag *)tagWithTagName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context;
@end
