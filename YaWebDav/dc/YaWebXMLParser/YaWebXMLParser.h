//
//  YaWebXMLParser.h
//  YaWebDav
//
//  Created by Korovkina Katerina on 29.04.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YaWebXMLParser;

@protocol YaWebXMLParserDelegate <NSObject>

- (void) parser:(YaWebXMLParser *)parser didEndParsingWithError:(NSError *)error;

- (void) parserDidStartParsing:(YaWebXMLParser *)parser;

- (void) parser:(YaWebXMLParser *)parser didFindElement:(NSDictionary *)dictionary;

@end

@interface YaWebXMLParser : NSObject


//Класс для парсинга данных
@property (nonatomic, weak) id<YaWebXMLParserDelegate> delegate;


/**
	Кастомный инициализатор объекта класса для парсинга
	@param data данные, которые необходимо распарсить
	@param edgeElement элемент, обозначающий границу одного элемента парсинга /граница файла в данном случае/
	@returns инициализированный объект парсера
 */
- (YaWebXMLParser *)initWithData:(NSData *)data edgeElement:(NSString *)edgeElement;

/**
	Метод для старта процесса парсинга
 */
- (void) parse;


@end


