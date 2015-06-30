//
//  UIView+ViewController.m
//  SGClientForiPhone
//
//  Created by yangboshan on 15/6/23.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#import "UIView+Category.h"

@implementation UIView (Category)

- (UIViewController *)viewController{
    
    UIResponder *next = [self nextResponder];
    
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        
        next = [next nextResponder];
        
    } while (next != nil);
    
    return nil;
}

@end
