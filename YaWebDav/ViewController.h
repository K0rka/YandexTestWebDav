//
//  ViewController.h
//  YaWebDav
//
//  Created by Korovkina Katerina on 27.04.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Folder.h"

@interface ViewController : UITableViewController//UIViewController
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic) NSFetchedResultsController *frc;
@property (nonatomic) Folder *folder;


- (void) initialLoad;


- (void) processLoadFinishWithError:(NSError *)error;
@end
