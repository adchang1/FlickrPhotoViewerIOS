//
//  ImageCache.h
//  SPoT
//
//  Created by Allen Chang on 2/16/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject
-(id)initWithCacheLimit:(long)limit;
- (UIImage *) getImage: (NSURL *) ImageURL; //will also do caching if image does not exist
@property(nonatomic) NSString *docDirPath;

@end
