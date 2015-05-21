//
//  SGPortPageDataModel.m
//  SGClient
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
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