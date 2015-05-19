//
//  SGScanViewController.h
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGBaseViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface SGScanViewController : SGBaseViewController<AVCaptureMetadataOutputObjectsDelegate>
-(void)afterwardsClean;

@end
