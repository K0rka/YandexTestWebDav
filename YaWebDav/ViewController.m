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
#import "FileTypeSortDescriptor.h"

@interface ViewController () <UIWebViewDelegate, NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, NSFetchedResultsControllerDelegate> {
    
    NSMutableArray *_elementsArray;
    
    NSMutableDictionary *_elementsDict;
    BaseFile *_currentObject;
    
    NSMutableString *_currentElement;
    NSMutableString *_currentElementValue;
    
    NSDictionary *_eqDict;
    
    NSDateFormatter *_startDateFormatter;
    NSDateFormatter *_lastModifiedDateFormatter;
    
      UIWebView *wView;
    
    
    Folder *_parent;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
//@property (retain, nonatomic) NSMutableArray *foldersArray;

@end

@implementation ViewController


//===============================================================================
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:kUserDidLogout object:nil];
}



//===============================================================================

- (void)setFolder:(Folder *)folder {
    
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
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


//===============================================================================
- (void) initialLoad {
    if (![[YaWebDAVDataController sharedInstance] accessToken]) {
        [self requestAccessToken];
    }
    else {
//        if (!((TableViewController *)self).folderArray)
        {
            [self didGetAccessToken];
        }
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
    //    [_webView setHidden:YES];
    
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
- (void) refresh  {
    __weak ViewController *wSelf = self;
    [[YaWebDAVDataController sharedInstance] getFoldersForFolder:self.folder withCompletionBlock:^(NSArray *folders, NSError *error) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wSelf processLoadFinishWithError:error];
        });
        
    }];
    
}

//===============================================================================
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

@end
