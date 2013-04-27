//
//  MasterViewController.h
//  YaWebDav
//
//  Created by Korovkina Katerina on 27.04.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
