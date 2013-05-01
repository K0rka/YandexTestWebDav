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

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //Задание в качестве правой кнопки NavigationBar'а кнопки обновления
    UIBarButtonItem *itm = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    
    self.navigationItem.rightBarButtonItem = itm;
    
    
    //Задание в качестве левого элемента NavigationBar'а кнопки логаута пользователя
    if ([[self.navigationController viewControllers] count] == 1) {
        
        UIBarButtonItem *itmLogout = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(logout)];
        
        self.navigationItem.leftBarButtonItem = itmLogout;
    }
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view data source
////////////////////////////////////////////////////////////////////////////////
//===============================================================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Пользуемся тем, что таблица не разделена на секции
    return self.frc.fetchedObjects.count;
}



//===============================================================================
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    BaseFile *fileToShow = [self.frc objectAtIndexPath:indexPath]; 

    //Пишем название файла
    cell.textLabel.text = fileToShow.displayName;
    
    //Создаем форматтер для отображения даты создания 
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy, HH:mm"];
    }
    
    cell.detailTextLabel.text = [dateFormatter stringFromDate:fileToShow.creationDate];
    
    
    //"Поиграем с цветами"
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
    //Определяем, какой объект выбрал пользователь
    BaseFile *selectedFile = [self.frc objectAtIndexPath:indexPath];
    
    
    //Если пользователь нажал на объект папки
    if ([selectedFile isKindOfClass:[Folder class]]) {
        
        //Создаем и показываем новый контролер с содержимым выбранной папки
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        TableViewController *tC = [storyBoard instantiateViewControllerWithIdentifier:@"TableVC"];
        [tC setManagedObjectContext:self.managedObjectContext];
        
        
        //Задаем новому контроллеру в качестве родительской папку, на которую нажал пользователь
        [tC setFolder:(Folder *)selectedFile];
        //Устанавливаем кнопку "Назад"
        [tC setLeftButtonToBackButton];
        [self.navigationController pushViewController:tC animated:YES];
        
        //Запрашиваем обновление данных для содержимого выбранной папки
        [[YaWebDAVDataController sharedInstance] getFoldersForFolder:(Folder *)selectedFile withCompletionBlock:^(NSArray *folders, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [tC processLoadFinishWithError:error];
            });

        }];
    }
    
    
    //Если пользователь нажал на "файл" просто снимаем выделение
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}




@end
