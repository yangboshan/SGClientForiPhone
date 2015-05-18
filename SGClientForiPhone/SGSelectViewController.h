//
//  SGSelectViewController.h
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/18.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGBaseViewController.h"

@protocol SGPortPageBussinessDelegate <NSObject>
-(void)userDidSelectItem:(NSInteger)index;
@end

@interface SGSelectViewController : SGBaseViewController

@property (nonatomic,strong) NSArray* dataSource;
@property (nonatomic,weak) id<SGPortPageBussinessDelegate> delegate;

@end
