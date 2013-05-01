//
//  YaWebDBSaver.m
//  YaWebDav
//
//  Created by Korovkina Katerina on 29.04.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

#import "YaWebDBSaver.h"
#import "BaseFile.h"
#import "File.h"


@interface YaWebDBSaver () {
    Folder *_parent;
    NSMutableArray *_childrenArray;
    
    NSSortDescriptor *_sortDesc;
    
    
    NSDateFormatter *_startDateFormatter;
    NSDateFormatter *_lastModifiedDateFormatter;
}


@end

@implementation YaWebDBSaver


//===============================================================================
static NSString *const kCreatioDate = @"creationdate";
static NSString *const kDisplayName = @"displayname";
static NSString *const kHref = @"href";
static NSString *const kLastModified = @"getlastmodified";
static NSString *const kContentLength = @"getcontentlength";
static NSString *const kContentType = @"getcontenttype";
//===============================================================================




//===============================================================================
- (YaWebDBSaver *)initWithParentFolder:(Folder *)_parentFolder {
    self = [super init];
    
    if (self) {
        _parent = _parentFolder;
        _sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
        
        _startDateFormatter = [[NSDateFormatter alloc] init];
        [_startDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        
        
        _lastModifiedDateFormatter = [[NSDateFormatter alloc] init];
        [_lastModifiedDateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZ"];

    }
    
    return self;
}



//===============================================================================
- (void) createChildrenArrayForParentFolder:(Folder *) folder {
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    //Если есть папка, которую парсим, то она же является родительской
    if (folder) {
        _parent = folder;
    }
    //Если папки нет, значит поиск ведется для корня
    else {
        //Ищем по базе запись для корневой папки
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"link == %@", @"/"];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Folder"];
        [request setPredicate:predicate];
        
        NSArray *arrayOfObjectsByHref = [moc executeFetchRequest:request error:nil];
        
        //Если корневая папка уже есть в базе
        if (arrayOfObjectsByHref.count) {
            _parent = [arrayOfObjectsByHref lastObject];
            
        }
        else {
            _parent = nil;
        }
    }
    //Собираем массив дочерних папок
    _childrenArray = [NSMutableArray arrayWithArray:[_parent.children sortedArrayUsingDescriptors:@[_sortDesc]]];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Maping to db
////////////////////////////////////////////////////////////////////////////////
//===============================================================================
//Метод работы с объектом, который будет создаваться из словаря dict
- (void) createNewObjectWithDictionary:(NSDictionary *)dict {
    //    NSDictionary *dictionary = dict;
    //Находим в словаре ссылку на объект
    NSString *href = [dict valueForKey:kHref];
    
    //Если она соответствует ссылке на родительскую папку, обновляем ее данными из словаря
    if ([_parent.link isEqual:href]) {
        
        [self updateObject:_parent withDictionary:dict];
        
    }
    
    //Объект либо в детях, либо его вообще нет
    else {
        
        __block BaseFile *object = nil;
        //Ищем объект, находящийся в словаре по дочерним элементам родительской папки
        [_childrenArray enumerateObjectsUsingBlock:^(BaseFile *obj, NSUInteger idx, BOOL *stop) {
            
            if ([obj.link isEqual:href]) {
                object = obj;
                *stop = YES;
            }
        }];
        
        //Если нашли объект среди дочерних
        if (object) {
            
            [_childrenArray removeObject:object];
            [self updateObject:object withDictionary:dict];
        }
        
        //Объект не нашли нигде в базе, его надо создавать
        else {
            //Если объект - папка
            if ([[dict valueForKey:@"collection"] isEqual:@(YES)]) {
                object = (Folder *)[NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:self.managedObjectContext];
                
                if (!_parent) {
                    _parent = object;
                }
                else {
                    object.parent = _parent;
                }
            }
            
            //Если объект - файл
            else {
                object = (File *)[NSEntityDescription insertNewObjectForEntityForName:@"File" inManagedObjectContext:self.managedObjectContext];
                object.parent = _parent;
                
            }
            [self.managedObjectContext save:nil];
            //Обновляем вновь созданный объект данными из словаря
            [self updateObject:object withDictionary:dict];
        }
    }
    
}



//===============================================================================
//Обновление данных об объекте в соответствии с полученным словарем
- (void) updateObject:(BaseFile *)file withDictionary:(NSDictionary *) dictionary {
    
    //проходимся по всем ключам, имеющимся в словаре и записываем их в соответствующие поля объекта
    for (NSString *nextValue in dictionary) {
        
        NSLog(@"nextValue = %@", nextValue);
        
        [nextValue hash];
        NSString *string = [dictionary valueForKey:nextValue];
        
        if ([nextValue isEqual:kCreatioDate]) {
            
            NSDate *date = [_startDateFormatter dateFromString:string];
            NSLog(@"creation date = %@", date);
            file.creationDate = date;
            
        }
        else if ([nextValue isEqual:kLastModified])
        {
            NSDate *date = [_lastModifiedDateFormatter dateFromString:string];
            NSLog(@"last modified date = %@", date);
            ((Folder *)file).lastModified = date;
            
        }
        else if ([nextValue isEqual:kHref]) {
            
            file.link = string;
            
            NSLog(@"string = %@ ", string);
        }
        else if ([nextValue isEqual:kDisplayName]) {
            file.displayName = string;
        }
        
    }
    
    [self.managedObjectContext save:nil];
    
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - YaWebXMLParser delegate
////////////////////////////////////////////////////////////////////////////////
- (void)parser:(YaWebXMLParser *)parser didFindElement:(NSDictionary *)dictionary {
    [self createNewObjectWithDictionary:dictionary];
}


//===============================================================================
- (void)parser:(YaWebXMLParser *)parser didEndParsingWithError:(NSError *)error {
    
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    //Все элементы, оставшиеся в этом массиве не пришли с сервера, значит их нужно удалить из базы
    for (NSManagedObject *nextObject in _childrenArray) {
        [moc deleteObject:nextObject];
    }
    [self.managedObjectContext save:nil];
    
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES];
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    
    NSArray *ar = [_parent.children sortedArrayUsingDescriptors:@[sort1, sort]];

    
    [_delegate saver:self didEndSaveWithElementsArray:ar error:error];
    
}


//===============================================================================
- (void)parserDidStartParsing:(YaWebXMLParser *)parser {
    [self createChildrenArrayForParentFolder:_parent];
}
@end
