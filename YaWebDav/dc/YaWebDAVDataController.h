//
//  YaWebDAVDataController.h
//  YaTestWebDAV
//
//  Created by Korovkina Katerina on 25.04.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Folder;
@interface YaWebDAVDataController : NSObject

@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


+ (YaWebDAVDataController *)sharedInstance;

- (NSURL *)urlToRequestAuthorization;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - User Methods
////////////////////////////////////////////////////////////////////////////////
//===============================================================================
/**
    Метод получения всех дочерних папок/файлов заданной папки. Если папка не задана, ищутся все дочерние для корневой папки. После окончания выполнения запроса и парсинга ответа вызывается completionBlock, где
    error - ошибка, произошедшая на этапе парсинга или выполнения запроса
    folders - все папки, дочерние элементы для заданной папки (содержащиеся в корневой, если никакая папка не задана)
   @param folder - папка, дочерние для которой будут искаться
 */
- (void) getFoldersForFolder:(Folder *)folder
         withCompletionBlock: (void (^)(NSArray *folders, NSError *error) )completionBlock;



//===============================================================================
- (void) getAllFoldersForCurrentUserStartingWithFolder:(Folder *)folder withCompletionBlock: (void (^)())completionBlock;



//===============================================================================
/**
	Метод для осуществления logout'а текущего пользователя
 */
- (void) logout;


- (void) showCantRefreshError;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Support Methods
////////////////////////////////////////////////////////////////////////////////

- (void) disableAllContentUsingLoader:(BOOL)showLoader;

- (void) enableAllcontent;

@end
