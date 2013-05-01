//
//  TableViewController.m
//  YaWebDav
//
//  Created by Korovkina Katerina on 27.04.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//


#import "TableViewController.h"
#import "YaWebDAVDataController.h"
#import "BaseFile.h"
#import "File.h"
#import "Folder.h"

@interface TableViewController () {
    NSMutableArray *_folderArray;
}

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //Задание в качестве правой кнопки NavigationBar'а кнопки обновления
    UIBarButtonItem *itm = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    
    self.navigationItem.rightBarButtonItem = itm;
    
    
    
    if ([[self.navigationController viewControllers] count] == 1) {
        
        UIBarButtonItem *itmLogout = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(logout)];
        
        self.navigationItem.leftBarButtonItem = itmLogout;
    }
}



//===============================================================================
//- (void)setFolderArray:(NSMutableArray *)folderArray {
//    _folderArray = folderArray;
//    [self.tableView reloadData];
//}


#pragma mark - Table view data source


//===============================================================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.frc.fetchedObjects.count;//_folderArray.count;
}



//===============================================================================
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    BaseFile *fileToShow = [self.frc objectAtIndexPath:indexPath]; //[_folderArray objectAtIndex:indexPath.row];

    cell.textLabel.text = fileToShow.displayName;
    
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy, HH:mm"];
    }
    
    cell.detailTextLabel.text = [dateFormatter stringFromDate:fileToShow.creationDate];
    
    if ([fileToShow isKindOfClass:[Folder class]]) {
        
        cell.contentView.backgroundColor = [UIColor colorWithRed:100./255 green:150./255 blue:255./255 alpha:0.3];
    }
    else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:255./255 green:150./255 blue:100./255 alpha:0.7];
    }
    
    [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];

    
    return cell;
}






////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view delegate
////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BaseFile *selectedFile = [self.frc objectAtIndexPath:indexPath];//[_folderArray objectAtIndex:indexPath.row];
    
    if ([selectedFile isKindOfClass:[Folder class]]) {
        
        //Создаем и показываем новый контролер
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        TableViewController *tC = [storyBoard instantiateViewControllerWithIdentifier:@"TableVC"];
        [tC setManagedObjectContext:self.managedObjectContext];
        [tC setFolder:(Folder *)selectedFile];
        [tC setLeftButtonToBackButton];
        [self.navigationController pushViewController:tC animated:YES];
        
        [[YaWebDAVDataController sharedInstance] getFoldersForFolder:(Folder *)selectedFile withCompletionBlock:^(NSArray *folders, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [tC processLoadFinishWithError:error];
            });

        }];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}




@end
