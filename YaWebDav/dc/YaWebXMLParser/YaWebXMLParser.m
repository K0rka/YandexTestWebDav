//
//  YaWebXMLParser.m
//  YaWebDav
//
//  Created by Korovkina Katerina on 29.04.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

#import "YaWebXMLParser.h"

@interface  YaWebXMLParser () <NSXMLParserDelegate>
{
    //Элемент XML-дерева, который парсится в текущий момент
    NSString *_currentElement;
    
    //Словарь с полями объекта
    NSMutableDictionary *_elementsDict;
    
    NSString *_edgeElement;
}

@property (nonatomic) NSXMLParser *parser;

@end


@implementation YaWebXMLParser


//Кастомная инициализация объекта класса
- (YaWebXMLParser *)initWithData:(NSData *)data edgeElement:(NSString *)edgeElement {
    
    self = [super init];
    
    if (self) {
        _edgeElement = edgeElement;
        self.parser = [[NSXMLParser alloc] initWithData:data];
        [self.parser setShouldProcessNamespaces:YES];
        [self.parser setShouldReportNamespacePrefixes:YES];
        [self.parser setShouldResolveExternalEntities:YES];
        [self.parser setDelegate:self];
    }
    
    return self;
    
}



//===============================================================================
- (void) parse {
    [self.parser parse];
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - XML Parser Methods
////////////////////////////////////////////////////////////////////////////////
//===============================================================================
- (void) parserDidStartDocument:(NSXMLParser *)parser {
    
    if ([_delegate respondsToSelector:@selector(parserDidStartParsing:)]) {
        [_delegate parserDidStartParsing:self];
    }
    
    //Создаем словарь для хранения полей разбираемого объекта
    _elementsDict = [NSMutableDictionary dictionary];

}


//===============================================================================
- (void)parserDidEndDocument:(NSXMLParser *)parser {

    if ([_delegate respondsToSelector:@selector(parser:didEndParsingWithError:)]) {
        [_delegate parser:self didEndParsingWithError:nil];
    }

}

//===============================================================================
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    //Предыдущим был элемент resourcetype, на основании следующего определяется тип элемента: файл или папка
    if ([_currentElement isEqual:@"resourcetype"]) {
        
        //Если это папка
        if ([elementName isEqual:@"collection"]) {
            [_elementsDict setValue:@(YES) forKey:@"collection"];
        }
        //Если это файл
        else {
            [_elementsDict setValue:@(NO) forKey:@"collection"];
        }
        
    }
    _currentElement = [NSMutableString stringWithString: elementName];
}


//===============================================================================
- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    
    //Закончилась обработка объекта файла/папки
    if ([elementName isEqualToString:_edgeElement]) {
        if ([_delegate respondsToSelector:@selector(parser:didFindElement:)]) {
            [_delegate parser:self didFindElement:_elementsDict];
        }
        NSLog(@"parser did found ElementDictionary: %@", _elementsDict);
        //Создаем новый объект, старый уже считается завершенным
        _elementsDict = [NSMutableDictionary dictionaryWithCapacity:0];
    }
}


//===============================================================================
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    NSString *value = [_elementsDict valueForKey:_currentElement];
    
    //Если для этого объекта значение по такому ключу уже есть, то добавляем к нему вновь найденное (проблема составных символов (умляутов))
    if (value) {
        [_elementsDict setValue:[NSString stringWithFormat:@"%@%@", value, string] forKey:_currentElement];
    }
    
    else {
        [_elementsDict setValue:string forKey:_currentElement];
    }
    
    
}



//===============================================================================
- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    if ([_delegate respondsToSelector:@selector(parser:didEndParsingWithError:)]) {
        [_delegate parser:self didEndParsingWithError:validationError];
    }
}


//===============================================================================
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if ([_delegate respondsToSelector:@selector(parser:didEndParsingWithError:)]) {
        [_delegate parser:self didEndParsingWithError:parseError];
    }
}




@end
