//
//  LoaderAlertView.m
//  looky
//
//  Created by Korovkina Katerina on 09.01.13.
//  Copyright (c) 2013 NeoSphere. All rights reserved.
//

#import "ActivityAlertView.h"


@interface ActivityAlertView ()

@property (nonatomic)  UIActivityIndicatorView *activity;
@property (nonatomic)  UIAlertView *alert;

@end


@implementation ActivityAlertView


//=======================================================================================================
- (ActivityAlertView *) initActivityAlertWithTitle:(NSString *)title {
    
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Initialization code
        _alert =  [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];//initWithTitle:title message:nil];
        
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_activity setHidesWhenStopped:YES];
        _activity.frame = CGRectMake(139.0f-18.0f, 50.0f, 37.0f, 37.0f);
        
        //Добавляем индикатор активноети в окошко
        [_alert addSubview:_activity];
        
    }
    return self;
}


//========================================================================================================
- (void) disableContentWithLoadingView:(BOOL)usingAlertView {


    [_alert show];
    
    
    if(usingAlertView) {
        [_activity startAnimating];
    }
    else{
        [_alert setHidden:YES];
    }
}



//========================================================================================================
- (void) enableContent {
    //Прячем затемнение
    [_alert dismissWithClickedButtonIndex:0 animated:YES];
}


@end
