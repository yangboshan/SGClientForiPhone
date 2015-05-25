//
//  SGPortViewController.h
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/18.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGBaseDrawViewController.h"


typedef NS_ENUM(NSInteger, kConnectTypeFlag){
    kConnectTypeFlagGoose = 0,
    kConnectTypeFlagGooseD,
    kConnectTypeFlagSV,
    kConnectTypeFlagSVD,
    kConnectTypeFlagGooseSV,
    kConnectTypeFlagGooseSVD
};

@interface SGPortViewController : SGBaseDrawViewController

@property (nonatomic,strong) NSString* portId;
@property (nonatomic,strong) NSString* cableType;
@property (nonatomic,strong) NSString* deviceName;
@end
