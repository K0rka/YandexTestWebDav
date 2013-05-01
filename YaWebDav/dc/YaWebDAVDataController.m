//
//  YaWebDAVDataController.m
//  YaTestWebDAV
//
//  Created by Korovkina Katerina on 25.04.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

#import "YaWebDAVDataController.h"
#import "SharedNotificationNames.h"
#import "ActivityAlertView.h"
#import "BaseFile.h"
#import "Folder.h"
#import "File.h"
#import "YaWebXMLParser.h"
#import "YaWebDBSaver.h"
#import "AppDelegate.h"

@interface YaWebDAVDataController () <YaWebXMLParserDelegate, YaWebXMLSaverDelegate, UIAlertViewDelegate> {
    NSMutableArray *_elementsArray;
    
    NSMutableDictionary *_elementsDict;
    BaseFile *_currentObject;
    
    NSMutableString *_currentElement;
    NSMutableString *_currentElementValue;
    
    NSDictionary *_eqDict;

    
    Folder *_parent;
    
    void(^_completionBlock)(NSArray *folders, NSError *error) ;
    
    NSMutableArray *_childrenArray;
    
    NSMutableArray *_mocsArray;
    NSManagedObjectContext *newMoc;
}

@property (nonatomic) Folder *folderToParse;
@property (nonatomic) ActivityAlertView *alertView;
@property (nonatomic) NSArray *sortDesc;


@end

@implementation YaWebDAVDataController

static NSString *const kApplicationId = @"74cf0116327146c992797499e7ea3c64";



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Shared Instance
////////////////////////////////////////////////////////////////////////////////
//===============================================================================
+ (YaWebDAVDataController *) sharedInstance {
    static YaWebDAVDataController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[YaWebDAVDataController alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *accessToken = [userDefaults valueForKey:kAccessTokenDefaultsKey];
        if (accessToken) {
            sharedInstance.accessToken = accessToken;
        }
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES];
        NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
        sharedInstance.sortDesc = @[sort, sort1];
        
    });
    
    return sharedInstance;
}





//===============================================================================
- (void) setAccessToken:(NSString *)accessToken {
    
    
    _accessToken = accessToken;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidGetAccessToken object:self];
    
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    [userDefaults setValue:_accessToken forKey:kAccessTokenDefaultsKey];
    
    [userDefaults synchronize];
}



//===============================================================================
- (NSURL *)urlToRequestAuthorization {
    NSString *string = [NSString stringWithFormat:@"https://oauth.yandex.ru/authorize?response_type=token&client_id=%@", kApplicationId];
    return [NSURL URLWithString:string];
}


//===============================================================================
- (void)getAllFoldersForCurrentUserStartingWithFolder:(Folder *)folder withCompletionBlock:(void (^)())completionBlock {
//    
////    dispatch_group_t resubscribeGroup = dispatch_group_create();
////    dispatch_group_enter(resubscribeGroup);
//
//    return;
//    [_mocsArray removeAllObjects];
//    [self disableAllContentUsingLoader:YES];
//    __weak   YaWebDAVDataController *wSelf = self;
//    [self getFoldersForFolder:folder withCompletionBlock:^(NSArray *folders, NSError *error) {
//
//        int i = 0;
//
//        for (BaseFile *nextFile in folders) {
//            if ([nextFile isKindOfClass:[Folder class]]) {
//                i++;
//
//                    [wSelf getAllFoldersForCurrentUserStartingWithFolder:(Folder *)nextFile withCompletionBlock:nil];
//
//            }
//        }
//
//        if (i==0) {
//        
//            [self enableAllcontent];
//            if (completionBlock) {
//                completionBlock();
//            }
//        }
////        dispatch_group_leave(resubscribeGroup);
//        
//    }];
//    //Завершение работы
////    dispatch_group_notify(resubscribeGroup, dispatch_get_main_queue(), ^{
//        
////    });
}


- (NSMutableURLRequest *)urlRequestForFolder:(Folder *)folder
{
    NSString *stringForURL = [NSString stringWithFormat:@"https://webdav.yandex.ru%@", folder ? folder.link : @"/"];
    
    NSURL *url = [NSURL URLWithString:stringForURL];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSString *accessValue = [NSString stringWithFormat:@"OAuth %@", self.accessToken];
    
    [urlRequest addValue:accessValue forHTTPHeaderField:@"Authorization"];
    [urlRequest addValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [urlRequest addValue:@"1" forHTTPHeaderField:@"Depth"];
    [urlRequest setHTTPMethod:@"PROPFIND"];
    return urlRequest;
}

//===============================================================================
- (void) getFoldersForFolder:(Folder *)folder
         withCompletionBlock: (void (^)(NSArray *folders, NSError *error) )completionBlock {
    
    NSManagedObjectID *folderID = nil;
    if (folder) {
       folderID = folder.objectID;

    }
    
    if (!_mocsArray.count) {
        _mocsArray = [NSMutableArray array];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //Создаем новый контекст для этой очереди

        
    if (!newMoc) {
        AppDelegate *theDelegate = [[UIApplication sharedApplication] delegate];
        newMoc = [[NSManagedObjectContext alloc] init];
        [newMoc setPersistentStoreCoordinator:[theDelegate persistentStoreCoordinator]];
        //
        // Register for context save changes notification
        NSNotificationCenter *notify = [NSNotificationCenter defaultCenter];
        [notify addObserver:self
                   selector:@selector(mergeChanges:)
                       name:NSManagedObjectContextDidSaveNotification
                     object:newMoc];
    }
    //            [_mocsArray addObject:newMoc];
    //        }
    __weak YaWebDAVDataController *wSelf = self;
    
    
    if (folderID) {
        _folderToParse = (Folder *)[newMoc objectWithID:folderID];
    }
    else{
        _folderToParse = nil;
    }
        NSMutableURLRequest *urlRequest = [self urlRequestForFolder:_folderToParse];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    
    NSURLResponse *response = nil;
    NSError *error = nil;
//
        //    sendSynchronousRequest:urlRequest returningResponse:&response error:&error];

   NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];//sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            NSLog(@"response = %@  error = %@", response, error );
            NSLog(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] );
        


            // Do the work
            // Your method here
            // Call save on context (this will send a save notification and call the method below)
//            BOOL success = [newMoc save:nil];
            //Если в результате не произошло ошибки, отправляем данные парситься
            if (!error) {
                
                if (completionBlock) {
                    _completionBlock = completionBlock;
                }
                YaWebXMLParser *parser = [[YaWebXMLParser alloc] initWithData:data edgeElement:@"resourse"];
                
                YaWebDBSaver *saver = [[YaWebDBSaver alloc] initWithParentFolder:_folderToParse];
                parser.delegate = saver;
                saver.delegate = wSelf;
                saver.managedObjectContext = newMoc;
                
                [parser parse];

            
            }
            //Если при загрузке произошла какая-то ошибка
            else {
                if (completionBlock) {
                    
                    NSArray *array = nil;
                    
                    //Если есть папка для парсинга, используем дочерние элементы, уже имеющиеся в базе
                    if (_folderToParse) {
                        array = [_folderToParse.children sortedArrayUsingDescriptors:self.sortDesc];
                    }
                    
                    //Если парсим корневой элемент
                    else {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"link == %@", @"/"];
                        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Folder"];
                        [request setPredicate:predicate];
                        
                        NSArray *arrayOfObjectsByHref = [newMoc executeFetchRequest:request error:nil];
                        
                        //Если корневой элемент найден, получаем все его дочерние элементы
                        if (arrayOfObjectsByHref.count) {

                            array = [[[arrayOfObjectsByHref lastObject] children] sortedArrayUsingDescriptors:self.sortDesc];
                        }
                    }
                    
                    // Do the work
                    // Your method here
                    // Call save on context (this will send a save notification and call the method below)
                    BOOL success = [newMoc save:nil];
                    completionBlock (array, error);
                }
            }
            
//        }];
    
    });
}



//===============================================================================
//Логаут пользователя
- (void)logout {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Чистим токен для этого пользователя
    [userDefaults removeObjectForKey:kAccessTokenDefaultsKey];
    
    [userDefaults synchronize];

    //Чистим базу для этого пользователя
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"BaseFile"];
    [request setIncludesSubentities:YES];
    
    
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    for (BaseFile *nextFile in array) {
        [self.managedObjectContext deleteObject:nextFile];
    }
    
    [self.managedObjectContext save:nil];
    
    //Чистим кэш и куки для того, чтобы новый запрос показал страницу с логиномо-паролем пользователя, а не с запросом разрешения
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSArray *cookiesToDelete = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[self urlToRequestAuthorization]];
    
    
    for (NSHTTPCookie *nextCookie in cookiesToDelete) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:nextCookie];
    }
    
    
    
    //Посылаем уведомление о том, что пользователь вышел из приложения
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidLogout object:self];
    
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
- (void)saver:(YaWebDBSaver *)saver didEndSaveWithElementsArray:(NSArray *)array error:(NSError *)error {
    
    [saver.managedObjectContext save:nil];//[newMoc save:nil];
    if (_completionBlock) {
        _completionBlock (array, error);
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Support Methods
////////////////////////////////////////////////////////////////////////////////
//Заблокировать взаимодействие с пользователем, используя крутилку-индикатор активности
- (void)disableAllContentUsingLoader:(BOOL)showLoader {
    if (!_alertView) {
        _alertView = [[ActivityAlertView alloc] initActivityAlertWithTitle:NSLocalizedString(@"Loading", "loading")];
        [_alertView disableContentWithLoadingView:showLoader];
    }
}


//===============================================================================
//Разблокировать возможность взаимодействия с пользователем
- (void)enableAllcontent {
    [_alertView enableContent];
}


//===============================================================================
- (void) showCantRefreshError {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "error")
                                                    message:NSLocalizedString(@"CantRefresh", "can't refresh")
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
}




//===============================================================================
- (void)mergeChanges:(NSNotification*)notification
{
    AppDelegate *theDelegate = [[UIApplication sharedApplication] delegate];
    [[theDelegate managedObjectContext] performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
}
@end
