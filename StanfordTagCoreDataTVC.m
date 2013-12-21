//
//  StanfordTagCoreDataTVC.m
//  CoreDataSPOT
//
//  Created by Allen Chang on 2/23/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "StanfordTagCoreDataTVC.h"
#import "FlickrFetcher.h"
#import "Photo+Init.h"
#import "Shared.h"
#import "Tag.h"
@interface StanfordTagCoreDataTVC ()

@end

@implementation StanfordTagCoreDataTVC

-(NSFetchRequest *)getCustomRequest{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"name != %@ AND name != %@ AND name != %@",@"landscape",@"portrait",@"cs193pspot"]; // all Tags EXCEPT a few specific ones
    return request;
}



// Just sets the Refresh Control's target/action since it can't be set in Xcode (bug?).

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Core Data SPoT"];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
}

// Whenever the table is about to appear, if we have not yet opened/created or demo document, do so.

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.managedObjectContext){
        [self useDemoDocument];
        
    }
    [self refresh];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Category"];
     Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
     cell.textLabel.text = [tag.name capitalizedString];
     cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", [tag.photos count]];
     
     return cell;
     
}


// Fires off a block on a queue to fetch data from Flickr.
// When the data comes back, it is loaded into Core Data by posting a block to do so on
//   self.managedObjectContext's proper queue (using performBlock:).
// Data is loaded into Core Data by calling photoWithFlickrInfo:inManagedObjectContext: category method.

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Fetch", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *photos = [FlickrFetcher stanfordPhotos];
        // put the photos in Core Data
        [self.managedObjectContext performBlock:^{
            for (NSDictionary *photo in photos) {
                [Photo photoWithFlickrInfo:photo inManagedObjectContext:self.managedObjectContext];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }];
    });
}

// Gets the NSIndexPath of the UITableViewCell which is sender.
// Then uses that NSIndexPath to find the Tag in question using NSFetchedResultsController.
// Prepares a destination view controller through the "setTag:" segue by sending that to it.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];  //can retrieve the indexPath in the model (aka the location of the model object)
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"Set Tag"]) {
            Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];  //if you have the location, then can use the FRC to retrieve the object in the database
            if ([segue.destinationViewController respondsToSelector:@selector(setTag:)])
            {
                
                [segue.destinationViewController performSelector:@selector(setTagModel:) withObject:tag];
            }
        }
    }
}

@end
