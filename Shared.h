//
//  SharedContext.h
//  CoreDataSPOT
//
//  Created by Allen Chang on 2/25/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Shared : NSObject
+(UIManagedDocument *)sharedDoc;
+(NSURL *)sharedURL;
@end
