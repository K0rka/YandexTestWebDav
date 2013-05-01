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


/**
	Класс таблицы
 */
@interface TableViewController : ViewController

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@end
