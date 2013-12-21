//
//  GenericPhotoCoreDataTVC.h
//  CoreDataSPOT
//
//  Created by Allen Chang on 2/23/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface GenericPhotoCoreDataTVC : CoreDataTableViewController

// The Model for this class.
//GIVEN a managedObjectContext (aka a database), display the table based on Tags

// Essentially specifies the database to look in to find all Tags to display in this table.
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


- (void)useDemoDocument;
- (void)setupFetchedResultsController;
-(NSFetchRequest *)getCustomRequest;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; //abstract
@end
