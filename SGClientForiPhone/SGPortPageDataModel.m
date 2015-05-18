//
//  SGPortPageDataModel.m
//  SGClient
//
//  Created by yangboshan on 14-8-4.
//  Copyright (c) 2014年 XLDZ. All rights reserved.
//

#import "SGPortPageDataModel.h"

@implementation SGPortPageDataModel
-(instancetype)init{
    if (self = [super init]) {
        self.leftChilds = [NSMutableArray array];
        self.rightChilds = [NSMutableArray array];
    }
    return self;
}
@end

@implementation SGPortPageChildData
-(instancetype)init{
    if (self = [super init]) {
        self.cntedProDes = [NSMutableArray array];
        self.mainProDes = [NSMutableArray array];
    }
    return self;
}
@end