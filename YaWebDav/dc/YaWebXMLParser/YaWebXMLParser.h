//
//  YaWebXMLParser.h
//  YaWebDav
//
//  Created by Korovkina Katerina on 29.04.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YaWebXMLParser;

/**
	Протокол для уведомления делегата об этапах парсинга данных
 */
@protocol YaWebXMLParserDelegate <NSObject>
@optional

/**
	Парсер закончил работу с ошибкой
	@param parser Парсер
	@param error Ошибка
 */
- (void) parser:(YaWebXMLParser *)parser didEndParsingWithError:(NSError *)error;


/**
	Парсер начал работу
	@param parser Парсер
 */
- (void) parserDidStartParsing:(YaWebXMLParser *)parser;


/**
	Парсер закончил разбор очередного объекта
	@param parser Парсер
	@param dictionary Словарь свойств объекта, обнаруженных при разборе XML-дерева
 */
- (void) parser:(YaWebXMLParser *)parser didFindElement:(NSDictionary *)dictionary;


@end

/**
	Парсер XML-дерева
 */
@interface YaWebXMLParser : NSObject



/**
	Делегат, которому парсер будет сообщать об этапах разбора данных.
*/
@property (nonatomic, weak) id<YaWebXMLParserDelegate> delegate;



/**
	Кастомный инициализатор объекта класса для парсинга
	@param data данные, которые необходимо распарсить
	@param edgeElement элемент, обозначающий границу одного объекта разбора /граница файла в данном случае/
	@returns инициализированный объект парсера
 */
- (YaWebXMLParser *)initWithData:(NSData *)data edgeElement:(NSString *)edgeElement;

/**
	Метод для запуска процесса парсинга
 */
- (void) parse;


@end


