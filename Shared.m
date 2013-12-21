//
//  SharedContext.m
//  CoreDataSPOT
//
//  Created by Allen Chang on 2/25/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "Shared.h"


static UIManagedDocument *document;
static NSURL *url;

@implementation Shared


+(NSURL *)sharedURL{
    url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Demo Document"];
    return url;
}

+(UIManagedDocument *)sharedDoc{

    if(!document){        
        document = [[UIManagedDocument alloc] initWithFileURL:[Shared sharedURL]];
    } 
    return document;
}

    
@end
