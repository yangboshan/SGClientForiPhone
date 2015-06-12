//
//  NSString+FRCategory.m
//  FileReaderForPad
//
//  Created by yangboshan on 15/3/27.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "NSString+Category.h"

@implementation NSString (Category)

+(BOOL)stringIsNilOrEmpty:(NSString*)s{
    return !(s && s.length);
}


+(NSString*)documentPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSLog(@"NSDocumentDirectory:%@",documentsDirectory);
    return documentsDirectory;
}

@end
