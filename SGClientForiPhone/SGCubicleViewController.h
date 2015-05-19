//
//  SGCubicleViewController.h
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGBaseViewController.h"
#import "NJKScrollFullScreen.h"

@interface SGCubicleViewController : SGBaseViewController<NJKScrollFullscreenDelegate>

//扫码功能调用接口
-(void)scanModeWithCubicleId:(NSInteger)cubicleId withCableId:(NSInteger)cableId;
-(void)scanModeWithPortId:(NSString*)portId;


@end
