//
//  FileTypeSortDescriptor.m
//  YaWebDav
//
//  Created by Korovkina Katerina on 01.05.13.
//  Copyright (c) 2013 Korovkina Katerina. All rights reserved.
//

#import "FileTypeSortDescriptor.h"
#import "BaseFile.h"
#import "File.h"
#import "Folder.h"


@implementation FileTypeSortDescriptor

//===============================================================================
- (id)copyWithZone:(NSZone*)zone
{
    return [[[self class] alloc] initWithKey:[self key] ascending:[self ascending] selector:[self selector]];
}

//===============================================================================
- (NSComparisonResult)compareObject:(id)object1 toObject:(id)object2 {
  
    Class class1 = [object1 class];
    Class class2 = [object2 class];
    
    if (class1 == class2) {
        return NSOrderedSame;
    }
    else if (class1 == [File class]) {
        return NSOrderedAscending;
    }
    else {
        return NSOrderedDescending;
    }
    
}
@end
