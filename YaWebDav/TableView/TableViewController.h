//
//  TableViewController.h
//  YaWebDav
//
//  Created by Korovkina Katerina on 27.04.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@class Folder;


@interface TableViewController : ViewController//UITableViewController

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;


@property (nonatomic) NSMutableArray *folderArray;
- (id) initWithFolder:(Folder *) folder;

- (void) setLeftButtonToBackButton;

@end
