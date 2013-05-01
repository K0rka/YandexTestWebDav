//
//  YaWebDBSaver.h
//  YaWebDav
//
//  Created by Korovkina Katerina on 29.04.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Folder.h"
#import "YaWebXMLParser.h"


@class YaWebDBSaver;

/**
	Протокол для сообщения об окончании процесса сохранения в базу
 */
@protocol YaWebXMLSaverDelegate <NSObject>
@optional

/**
	Метод для сообщения об окончании процесса сохранения в базу
	@param saver Объект, который занимался сохранением в базу
	@param array Массив сохраненных в базу элементов
	@param error Ошибка, возникшая в результате сохранения
 */
- (void) saver:(YaWebDBSaver *)saver didEndSaveWithElementsArray:(NSArray *)array error:(NSError *)error;

@end


/**
	Класс для сохранения объектов в базу
 */
@interface YaWebDBSaver : NSObject <YaWebXMLParserDelegate>

/**
	Инициализация объекта для сохранения с заданной родительской папкой.
	@param _parentFolder Папка, которая будет считаться родительской для всех сохраняемых объектов
	@returns Инициализированный объект
 */
- (YaWebDBSaver *) initWithParentFolder:(Folder *)_parentFolder;


/**
	Делегат, реализующий протокол YaWebXMLSaverDelegate. Используется для получения данных, сохраняемых в базу
 */
@property (nonatomic, weak) id<YaWebXMLSaverDelegate> delegate;

@property (nonatomic) NSManagedObjectContext *managedObjectContext;

@end


