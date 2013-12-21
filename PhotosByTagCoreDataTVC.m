//
//  PhotosByTagCoreDataTVC.m
//  CoreDataSPOT
//
//  Created by Allen Chang on 2/23/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "PhotosByTagCoreDataTVC.h"
#import "Photo.h"

@interface PhotosByTagCoreDataTVC ()

@end

@implementation PhotosByTagCoreDataTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    if(!self.managedObjectContext){
        [self useDemoDocument];
    }
    
}

// Creates an NSFetchRequest for Photos sorted by their title where the tag relationship contains our model's tag.
// Note that we have the NSManagedObjectContext we need by asking our Model (the Tag) for it.
//Alternatively, why not look into the Tag's photos attribute and get the NSSet there? Because then we'd have to manually sort the results.  This way, we let the database do the sorting.
-(NSFetchRequest *)getCustomRequest{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"%@ in tag", self.tag];
    return request;
}


// When our Model is set here, we update our title to be the Tag's name
//   and then set up our NSFetchedResultsController to make a request for Photos associated with that Tag.

- (void)setTagModel:(Tag *)tag
{
    _tag = tag;
    self.title = tag.name;  //set the main title bar at the top
    [self setupFetchedResultsController];
}



//required method for all TableViewControllers....cell setup!
// Uses NSFetchedResultsController's objectAtIndexPath: to find the Photo for this row in the table.
// Then uses that Photo to set the cell up.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Category"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [photo.title capitalizedString];
    cell.detailTextLabel.text = photo.about;
    UIImage *image = [[UIImage alloc] initWithData:photo.thumbdata];
    cell.imageView.image = image; 
    return cell;
}


// prepares for the "Show Image" segue by seeing if the destination view controller of the segue
//  understands the method "setImageURL:"
// if it does, it sends setImageURL: to the destination view controller with
//  the URL of the photo that was selected in the UITableView as the argument
// also sets the title of the destination view controller to the photo's title

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender   //this is a required method.  When you press a cell that is wired up to segue, it will call this and it will be the "sender".
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];  //the cell you pressed is auto set as the sender. It should be a Photo object
        if (indexPath) {
            Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
            NSString *urlString;
            
            if ([segue.identifier isEqualToString:@"Show Image"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {  //segues can give you the dest VC as an object so you can remote manipulate it!
                    
                    if(self.splitViewController){  //check if you're on iPad, set photo size accordingly
                        urlString = photo.urlipad;
                    }
                    else{  //otherwise you're on iPhone.
                        urlString = photo.url;
                    }
                    NSURL *url = [[NSURL alloc] initWithString:urlString];
                    
                    photo.datemodified = [NSDate date]; //updates the date modified attribute of this photo to show it was recently accessed
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    [segue.destinationViewController setTitle:photo.title];
                }
            }
        }
    }
}



@end
