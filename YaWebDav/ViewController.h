//
//  ViewController.h
//  YaWebDav
//
//  Created by Korovkina Katerina on 27.04.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Folder.h"

@interface ViewController : UITableViewController

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

/**
	Объект, хранящий структуру текущей таблицы
 */
@property (nonatomic) NSFetchedResultsController *frc;

/**
	Родительская папка текущей таблицы
 */
@property (nonatomic) Folder *folder;



/**
	Начальная загрузка: проверяется наличие авторизации у пользователя, при ее отсутствии происходит запрос авторизации
 */
- (void) initialLoad;



/**
	Обработка окончания загрузки данных
	@param error Ошибка, возникшая в результате загрузки данных
 */
- (void) processLoadFinishWithError:(NSError *)error;


/**
 Установить в качестве левой кнопки navigationBar'а кнопку "Назад"
 */
- (void) setLeftButtonToBackButton;

@end
