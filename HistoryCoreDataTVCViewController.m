//
//  HistoryCoreDataTVCViewController.m
//  CoreDataSPOT
//
//  Created by Allen Chang on 2/24/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "HistoryCoreDataTVCViewController.h"
#import "Shared.h"
#define FETCH_LIMIT 10
@interface HistoryCoreDataTVCViewController ()

@end

@implementation HistoryCoreDataTVCViewController

// Just sets the Refresh Control's target/action since it can't be set in Xcode (bug?).

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Recent History"];
}

// Whenever the table is about to appear, if we have not yet opened/created or demo document, do so.

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext){
        [self useDemoDocument]; 
    }
    [self setupFetchedResultsController];
}

-(NSFetchRequest *)getCustomRequest{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    [request setFetchLimit:FETCH_LIMIT];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"datemodified" ascending:NO selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"datemodified != nil"];  //only get entries that have datemodified set (means they have been looked at)
    return request;
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
