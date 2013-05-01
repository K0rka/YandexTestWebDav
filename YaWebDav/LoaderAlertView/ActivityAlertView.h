//
//  LoaderAlertView.h
//  looky
//
//  Created by Korovkina Katerina on 09.01.13.
//  Copyright (c) 2013 NeoSphere. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityAlertView : UIView

/**
	Метод создания объекта класса alertView с заданным названием и индикатором активности UIActivityIndicatorView
	@param title название создаваемого alertView (может быть nil)
	@returns инициализированный объект класса LoaderAlertView
 */
- (ActivityAlertView *) initActivityAlertWithTitle:(NSString *)title;

/**
	Метод для предотващения доступа пользователя к интерфейсу приложения
	@param usingAlertView использовать ли при этой алертвьюшку за крутилкой, или просто затемнение
 */
- (void) disableContentWithLoadingView:(BOOL)usingAlertView;

/**
	Метод для возвращения доступа пользователя к интерфейсу приложения
 */
- (void) enableContent;


@end
