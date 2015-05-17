//
//  SGSectionHeaderView.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/17.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "SGSectionHeaderView.h"
#import "SGMacro.h"


@implementation SGSectionHeaderView

- (void)awakeFromNib {
    self.roomLabel.textColor = [UIColor darkGrayColor];
    self.roomLabel.font = Lantinghei(22);
}

@end
