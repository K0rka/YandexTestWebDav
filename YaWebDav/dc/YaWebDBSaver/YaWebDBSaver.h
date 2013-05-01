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
@protocol YaWebXMLSaverDelegate <NSObject>

- (void) saver:(YaWebDBSaver *)saver didEndSaveWithElementsArray:(NSArray *)array error:(NSError *)error;

@end


@interface YaWebDBSaver : NSObject <YaWebXMLParserDelegate>

- (YaWebDBSaver *) initWithParentFolder:(Folder *)_parentFolder;

@property (nonatomic, weak) id<YaWebXMLSaverDelegate> delegate;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;

@end


