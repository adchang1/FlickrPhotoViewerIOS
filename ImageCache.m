//
//  ImageCache.m
//  SPoT
//
//  Created by Allen Chang on 2/16/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//  Credit for parts of this class goes to http://www.makebetterthings.com/iphone/image-caching-in-iphone-sdk/

#import "ImageCache.h"
@interface ImageCache()
@property(nonatomic) NSMutableArray *NSURLStringArray;   //oldest is at index 0; newest is at the tip!
@property(nonatomic) long cacheSizeLimit;
@property(nonatomic) long cacheSizeAllocated;
@end

@implementation ImageCache

-(id)initWithCacheLimit:(long)limit{
    if(self = [super init]){
        self.cacheSizeLimit = limit;
    }

    //examine sandbox files and init the state of the cache accordingly
    
    [self synchronizeCache];
    return self;
 
}

-(NSArray *)sortFilesByModDate:(NSArray *)fileStringList{  //input args still need documents path appended
    // sort by creation date
    NSMutableArray* filesAndProperties = [[NSMutableArray alloc]init];
    for(NSString* filePath in fileStringList) {
        NSString *fullFilePath = [self.docDirPath stringByAppendingPathComponent:filePath];
        NSDictionary* properties = [[NSFileManager defaultManager]
                                    attributesOfItemAtPath:fullFilePath
                                    error:nil];   //pulls all attributes of file into a dictionary
        NSDate* modDate = [properties objectForKey:NSFileModificationDate];  //extract the modification date, specifically
        
   
        [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           fullFilePath, @"path",
                                           modDate, @"lastModDate",
                                           nil]];  //create a dictionary with has the path and date as objects and add to an array of such dictionaries
   
    }
    
    // sort using a block
    // ordered newest file last
    NSArray* sortedDictionaries = [filesAndProperties sortedArrayUsingComparator:
                            ^(id path1, id path2)
                            {
                                // compare
                                NSComparisonResult comp = [[path1 objectForKey:@"lastModDate"] compare:
                                                           [path2 objectForKey:@"lastModDate"]];
                                return comp;
                            }];
    NSMutableArray *sortedFiles = [[NSMutableArray alloc]init];
    for(int index=0;index<[sortedDictionaries count];index++){
        NSDictionary *photoDict = (NSDictionary *)sortedDictionaries[index];
        [sortedFiles addObject:photoDict[@"path"]];
    }
    return sortedFiles;
    
}

-(void)synchronizeCache{  //do this whenever you load the view (switching between Featured and History)
    NSArray *existing = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.docDirPath error:nil];
    self.NSURLStringArray = [[self sortFilesByModDate:existing] mutableCopy];
    
    //update cache allocationSize by going through all files and adding up size
    self.cacheSizeAllocated=0;
    for(NSString *filePath in self.NSURLStringArray){
        self.cacheSizeAllocated=self.cacheSizeAllocated +[self getFileSize:filePath];
    }

}

-(NSString *)docDirPath{
    if(!_docDirPath){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _docDirPath = [paths objectAtIndex:0];
    }
    return _docDirPath;
}

-(long)cacheSizeAllocated{
    if(!_cacheSizeAllocated){
        return 0;
    }
    return _cacheSizeAllocated;
}


-(long)getFileSize:(NSString *)URLString{
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:URLString error:nil];
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    long fileSize = [fileSizeNumber longValue];
    return fileSize;
}

-(NSString *)generateUniquePath: (NSURL *)ImageURL{   //unique path generation idea is credited to http://www.makebetterthings.com/iphone/image-caching-in-iphone-sdk/
    NSString *stringURL = [ImageURL path];   //retrieve NSFileManager compatible path
    
    //generating unique name for the cached file with ImageURLString so you can retrive it back
    NSMutableString *tmpStr = [NSMutableString stringWithString:stringURL];
    [tmpStr replaceOccurrencesOfString:@"/" withString:@"-" options:1 range:NSMakeRange(0, [tmpStr length])];
    
    NSString *filename = [NSString stringWithFormat:@"%@",tmpStr];
    
    return [self.docDirPath stringByAppendingPathComponent: filename];
    
    
}

-(void)refreshURL:(NSURL*)newURL{
    NSString *uniquePath = [self generateUniquePath:newURL];
    for(int index=0; index<[self.NSURLStringArray count];index++){  //first update the URLStringArray
        NSString *selectedPath = self.NSURLStringArray[index];
        if([uniquePath isEqualToString:selectedPath]){   //you found that existing URL
            [self.NSURLStringArray removeObjectAtIndex:index];  //remove then reAdd at tip of Array
            [self.NSURLStringArray addObject:uniquePath];
        }
    }
    
    //now touch the modification date
    //first create an attribute dictionary of the key that you want to modify (NSFileModificationDate), and the value (current date)
NSDictionary *attribute = [[NSDictionary alloc]initWithObjectsAndKeys:[NSDate date],@"NSFileModificationDate", nil];
    [[NSFileManager defaultManager] setAttributes:attribute ofItemAtPath:uniquePath error:nil];  //now set the attributes using the dictionary!
}

-(void)removeOldestURL{
    NSString *oldestPath = [self.NSURLStringArray objectAtIndex:0];
    long filesize = [self getFileSize:oldestPath];
    self.cacheSizeAllocated=self.cacheSizeAllocated-filesize;  //update cache utilization
    
    [[NSFileManager defaultManager] removeItemAtPath:oldestPath error:nil]; //now delete the actual file
    
    [self.NSURLStringArray removeObjectAtIndex:0];    //remove the file from the index
    
    
}

- (void) cacheImage: (NSURL *) ImageURL   //template structure of cacheImage method is credited to http://www.makebetterthings.com/iphone/image-caching-in-iphone-sdk/ ....most pointedly, PNG/JPEG writing
{   
    NSString *uniquePath = [self generateUniquePath:ImageURL];
        
    // Fetch image
    NSData *data = [[NSData alloc] initWithContentsOfURL: ImageURL];
    UIImage *image = [[UIImage alloc] initWithData: data];
    
    // Is it PNG or JPG/JPEG?
    // Running the image representation function writes the data from the image to a file
    if([uniquePath rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound)
    {
        [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
    }
    else if(
            [uniquePath rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound ||
            [uniquePath rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound
            )
    {
        [UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
    }
    
    //add the URL String to the URLStringArray
    [self.NSURLStringArray addObject:uniquePath];
    
    //check to see if we have exceeded the cache size limit.  If so..
    long thisFileSize = [self getFileSize:uniquePath];
    
    self.cacheSizeAllocated = self.cacheSizeAllocated + thisFileSize;
    
    //start an eviction loop that only ends if we are under the cache size limit
    while(self.cacheSizeAllocated>self.cacheSizeLimit){
        
        [self removeOldestURL];
        
    }
    
    
}



- (UIImage *) getImage: (NSURL *) ImageURL  //template structure of cacheImage method is credited to http://www.makebetterthings.com/iphone/image-caching-in-iphone-sdk/
{
    if(!ImageURL){  //for ipad, the initial image in split screen mode starts as nothing
        return nil;
    }
    NSString *uniquePath = [self generateUniquePath:ImageURL];
    UIImage *image;
    
    // Check for a cached version
    if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath]){ //if does not exist yet, add it!
        [self cacheImage: ImageURL];
    }
    else{   //if it does already exist, refresh its "newness"(by removing it and adding it to the tip of the array again, and also touching the modification date to make the file itself "new")
        [self refreshURL:ImageURL];
    }

    NSData *data = [[NSData alloc] initWithContentsOfFile:uniquePath];
    image = [[UIImage alloc] initWithData:data] ; // this is the cached image
    
    return image;
}


@end