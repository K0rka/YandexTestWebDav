//
//  BaseFile.h
//  YaWebDav
//
//  Created by Korovkina Katerina on 01.05.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


/**
	Перечисление возможных типов файлов
 */
typedef enum FileType {
	FileTypeFolder, /**< "Папка" */
	FileTypeFile /**< "Файл" */
} FileType;



@class BaseFile, Folder;

@interface BaseFile : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * fileType;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) Folder *parent;
@end

@interface BaseFile (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(BaseFile *)value;
- (void)removeChildrenObject:(BaseFile *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

@end
