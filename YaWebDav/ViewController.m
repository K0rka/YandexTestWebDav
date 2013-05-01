//
//  ViewController.m
//  YaTestWebDAV
//
//  Created by Korovkina Katerina on 24.04.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

#import "ViewController.h"
#import "SharedNotificationNames.h"
#import "BaseFile.h"
#import "YaWebDAVDataController.h"
#import "File.h"
#import "Folder.h"
#import "TableViewController.h"

@interface ViewController () <UIWebViewDelegate, NSXMLParserDelegate, UIAlertViewDelegate, NSFetchedResultsControllerDelegate> {
    
    //вьюшка для отображения запроса авторизации
    UIWebView *wView;
}

@end

@implementation ViewController


//===============================================================================
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Подписываемся на уведомления о том, что пользователь осуществил logout
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:kUserDidLogout object:nil];
}



//===============================================================================
//Установка новой папки, пересоздаем под нее NSFetchedResultsController
- (void)setFolder:(Folder *)folder {
    //Запрашиваем все файлы, у которых родителем выступает текущая папка. Если папка не задана, родитель - корень
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent.link == %@", folder? folder.link : @"/"];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"BaseFile"];
    [request setPredicate:predicate];
    [request setIncludesSubentities:YES];
    [request setSortDescriptors:[[YaWebDAVDataController sharedInstance] sortedDescriptors]];
    
    [NSFetchedResultsController deleteCacheWithName: _folder? _folder.link : @"rootFolders"];
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                   managedObjectContext:self.managedObjectContext
                                                     sectionNameKeyPath:nil
                                                              cacheName: folder? folder.link : @"rootFolders"];
    self.frc.delegate = self;
    
    _folder = folder;

    NSError *error = nil;
    [self.frc performFetch:&error];
}


//===============================================================================
//Начальная конфигурация контроллера
- (void) initialLoad {
    //Если пользователь еще не авторизован
    if (![[YaWebDAVDataController sharedInstance] accessToken]) {
        //Запрашиваем авторизацию
        [self requestAccessToken];
    }
    else {
        //Говорим, что контроллер готов к работе
        [self didGetAccessToken];
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Notifications
////////////////////////////////////////////////////////////////////////////////
- (void) userDidLogout {
    //Если пользователь разавторизовался, надо запросить токен еще раз
    [self requestAccessToken];
}



//===============================================================================
- (void) didGetAccessToken {    
    [wView removeFromSuperview];
    [self.tableView setHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
    
    //    [[YaWebDAVDataController sharedInstance] getAllFoldersForCurrentUserStartingWithFolder:nil withCompletionBlock:nil];
    
    
    __weak ViewController *wSelf = self;
    [[YaWebDAVDataController sharedInstance] getFoldersForFolder:nil withCompletionBlock:^(NSArray *folders, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wSelf processLoadFinishWithError:error];
        });
        
    }];
    
}



//===============================================================================
- (void) processLoadFinishWithError:(NSError *)error {
    
    //Если получили ошибку во время загрузки и данных для отображения на экране нет, то показываем пользователю сообщение об ошибке
    if (error && !self.frc.fetchedObjects.count) {
        
        [[YaWebDAVDataController sharedInstance] showCantRefreshError];
        
    }
}

//===============================================================================
- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action
////////////////////////////////////////////////////////////////////////////////
//Обновление данных по текущей открытой папке пользователя
- (void) refresh  {
    __weak ViewController *wSelf = self;
    [[YaWebDAVDataController sharedInstance] getFoldersForFolder:self.folder withCompletionBlock:^(NSArray *folders, NSError *error) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wSelf processLoadFinishWithError:error];
        });
        
    }];
    
}

//===============================================================================
//Обработка нажатия на кнопку логаута
- (void) logout {
    [[YaWebDAVDataController sharedInstance] logout];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Support
////////////////////////////////////////////////////////////////////////////////
- (void) requestAccessToken {

    if (!wView) {
        wView = [[UIWebView alloc] initWithFrame:self.view.frame];
        wView.delegate = self;
    }
    [self.view addSubview:wView];
    [self.navigationController setNavigationBarHidden:YES];

    NSURLRequest *request = [NSURLRequest requestWithURL:[[YaWebDAVDataController sharedInstance] urlToRequestAuthorization]];
    
    [wView loadRequest:request];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAccessToken) name:kDidGetAccessToken object:nil];
}


//===============================================================================
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if (![error.domain isEqualToString:NSURLErrorDomain]) {
        return;
    }
    
    UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "error")
                                                   message:NSLocalizedString(@"ErrorWhileGetAccessToken", "")
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Retry", "") otherButtonTitles:nil];
    [alrt show];
}



//===============================================================================
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self requestAccessToken];
}



//===============================================================================
- (void) setLeftButtonToBackButton {
    
    self.navigationItem.rightBarButtonItem = self.navigationItem.backBarButtonItem;
}
@end
