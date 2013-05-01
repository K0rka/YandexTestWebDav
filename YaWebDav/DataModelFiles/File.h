//
//  File.h
//  YaWebDav
//
//  Created by Korovkina Katerina on 28.04.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BaseFile.h"


@interface File : BaseFile

@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSString * etag;

@end
