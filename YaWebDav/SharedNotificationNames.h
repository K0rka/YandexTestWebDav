//
//  SharedNotificationNames.h
//  YaTestWebDAV
//
//  Created by Korovkina Katerina on 25.04.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

// Имя уведомления о том, что был получен accessToken
static NSString *const kDidGetAccessToken = @"DidGetAccessToken";

// Имя ключа в userDefaults'ах, по которому хранится accessToken авторизовавшегося пользователя
static NSString *const kAccessTokenDefaultsKey = @"AccessTokenDefautlsKey";

// Имя уведомления о том, что пользователь осуществил логаут
static NSString *const kUserDidLogout = @"UserDidLogout";