//
//  PhotosByTagCoreDataTVC.h
//  CoreDataSPOT
//
//  Created by Allen Chang on 2/23/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "GenericPhotoCoreDataTVC.h"
#import "Tag.h"

@interface PhotosByTagCoreDataTVC : GenericPhotoCoreDataTVC

// The Model for this class.
// It displays all the Photo objects marked with this Tag
//   (i.e. all Photo objects whose "Tag" set contains this Tag).
@property (nonatomic, strong) Tag *tag;
- (void)setTagModel:(Tag *)tag;

@end
