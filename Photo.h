//
//  Photo.h
//  CoreDataSPOT
//
//  Created by Allen Chang on 2/23/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * thumburl;
@property (nonatomic, retain) NSString * ident;
@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) NSDate * datemodified;
@property (nonatomic, retain) NSData * thumbdata;
@property (nonatomic, retain) NSString * urlipad;
@property (nonatomic, retain) NSSet *tag;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addTagObject:(Tag *)value;
- (void)removeTagObject:(Tag *)value;
- (void)addTag:(NSSet *)values;
- (void)removeTag:(NSSet *)values;

@end
